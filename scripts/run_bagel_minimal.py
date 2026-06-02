#!/usr/bin/env python3
# Copyright 2025 Bytedance Ltd. and/or its affiliates.
# SPDX-License-Identifier: Apache-2.0

"""Minimal BAGEL CLI that bypasses Gradio and calls InterleaveInferencer."""

from __future__ import annotations

import argparse
import os
import random
import subprocess
import sys
import time
from pathlib import Path
from typing import Sequence

import numpy as np
import torch
from accelerate import infer_auto_device_map, init_empty_weights, load_checkpoint_and_dispatch
from accelerate.utils import BnbQuantizationConfig, load_and_quantize_model
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from data.data_utils import add_special_tokens, pil_img2rgb  # noqa: E402
from data.transforms import ImageTransform  # noqa: E402
from inferencer import InterleaveInferencer  # noqa: E402
from modeling.autoencoder import load_ae  # noqa: E402
from modeling.bagel import (  # noqa: E402
    Bagel,
    BagelConfig,
    Qwen2Config,
    Qwen2ForCausalLM,
    SiglipVisionConfig,
    SiglipVisionModel,
)
from modeling.qwen2 import Qwen2Tokenizer  # noqa: E402


def str2bool(value: str | bool) -> bool:
    if isinstance(value, bool):
        return value
    lowered = value.lower()
    if lowered in {"1", "true", "yes", "y", "on"}:
        return True
    if lowered in {"0", "false", "no", "n", "off"}:
        return False
    raise argparse.ArgumentTypeError(f"invalid boolean value: {value}")


def parse_cfg_interval(value: str) -> list[float]:
    parts = [p.strip() for p in value.split(",") if p.strip()]
    if len(parts) == 1:
        start = float(parts[0])
        return [start, 1.0]
    if len(parts) == 2:
        return [float(parts[0]), float(parts[1])]
    raise argparse.ArgumentTypeError("--cfg_interval must be a float or start,end")


def parse_image_shape(value: str) -> tuple[int, int]:
    normalized = value.lower().replace("x", ",")
    parts = [p.strip() for p in normalized.split(",") if p.strip()]
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("--image_shape must be H,W, for example 1024,1024")
    return int(parts[0]), int(parts[1])


def set_seed(seed: int) -> None:
    if seed > 0:
        random.seed(seed)
        np.random.seed(seed)
        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed(seed)
            torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False


def gpu_memory_summary() -> str:
    if not torch.cuda.is_available():
        return "cuda_available=False"

    torch_parts = []
    for i in range(torch.cuda.device_count()):
        allocated = torch.cuda.memory_allocated(i) / 1024**3
        reserved = torch.cuda.memory_reserved(i) / 1024**3
        peak = torch.cuda.max_memory_allocated(i) / 1024**3
        torch_parts.append(
            f"cuda:{i} torch_allocated={allocated:.2f}GiB "
            f"torch_reserved={reserved:.2f}GiB torch_peak={peak:.2f}GiB"
        )

    try:
        smi = subprocess.run(
            [
                "nvidia-smi",
                "--query-gpu=index,memory.used,memory.total",
                "--format=csv,noheader,nounits",
            ],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
        if smi.stdout.strip():
            torch_parts.append("nvidia_smi=" + " | ".join(smi.stdout.strip().splitlines()))
    except Exception as exc:  # pragma: no cover - diagnostic only
        torch_parts.append(f"nvidia_smi_error={exc}")

    return "; ".join(torch_parts)


def build_inferencer(model_path: str, mode: int) -> InterleaveInferencer:
    llm_config = Qwen2Config.from_json_file(os.path.join(model_path, "llm_config.json"))
    llm_config.qk_norm = True
    llm_config.tie_word_embeddings = False
    llm_config.layer_module = "Qwen2MoTDecoderLayer"

    vit_config = SiglipVisionConfig.from_json_file(os.path.join(model_path, "vit_config.json"))
    vit_config.rope = False
    vit_config.num_hidden_layers -= 1

    vae_model, vae_config = load_ae(local_path=os.path.join(model_path, "ae.safetensors"))

    config = BagelConfig(
        visual_gen=True,
        visual_und=True,
        llm_config=llm_config,
        vit_config=vit_config,
        vae_config=vae_config,
        vit_max_num_patch_per_side=70,
        connector_act="gelu_pytorch_tanh",
        latent_patch_size=2,
        max_latent_size=64,
    )

    with init_empty_weights():
        language_model = Qwen2ForCausalLM(llm_config)
        vit_model = SiglipVisionModel(vit_config)
        model = Bagel(language_model, vit_model, config)
        model.vit_model.vision_model.embeddings.convert_conv2d_to_linear(vit_config, meta=True)

    tokenizer = Qwen2Tokenizer.from_pretrained(model_path)
    tokenizer, new_token_ids, _ = add_special_tokens(tokenizer)

    vae_transform = ImageTransform(1024, 512, 16)
    vit_transform = ImageTransform(980, 224, 14)

    device_map = infer_auto_device_map(
        model,
        max_memory={**{i: "20GiB" for i in range(torch.cuda.device_count())}, "cpu": "80GiB"},
        no_split_module_classes=["Bagel", "Qwen2MoTDecoderLayer"],
    )

    same_device_modules = [
        "language_model.model.embed_tokens",
        "time_embedder",
        "latent_pos_embed",
        "vae2llm",
        "llm2vae",
        "connector",
        "vit_pos_embed",
    ]

    if torch.cuda.device_count() == 1:
        first_device = device_map.get(same_device_modules[0], "cuda:0")
        for key in same_device_modules:
            device_map[key] = device_map.get(key, first_device)
    else:
        first_device = device_map.get(same_device_modules[0])
        for key in same_device_modules:
            if key in device_map:
                device_map[key] = first_device

    checkpoint_path = os.path.join(model_path, "ema.safetensors")
    if mode == 1:
        model = load_checkpoint_and_dispatch(
            model,
            checkpoint=checkpoint_path,
            device_map=device_map,
            offload_buffers=True,
            offload_folder="offload",
            dtype=torch.bfloat16,
            force_hooks=True,
        ).eval()
    elif mode == 2:
        bnb_quantization_config = BnbQuantizationConfig(
            load_in_4bit=True,
            bnb_4bit_compute_dtype=torch.bfloat16,
            bnb_4bit_use_double_quant=False,
            bnb_4bit_quant_type="nf4",
        )
        model = load_and_quantize_model(
            model,
            weights_location=checkpoint_path,
            bnb_quantization_config=bnb_quantization_config,
            device_map=device_map,
            offload_folder="offload",
        ).eval()
    elif mode == 3:
        bnb_quantization_config = BnbQuantizationConfig(load_in_8bit=True, torch_dtype=torch.float32)
        model = load_and_quantize_model(
            model,
            weights_location=checkpoint_path,
            bnb_quantization_config=bnb_quantization_config,
            device_map=device_map,
            offload_folder="offload",
        ).eval()
    else:
        raise ValueError("--mode must be one of: 1, 2, 3")

    return InterleaveInferencer(
        model=model,
        vae_model=vae_model,
        tokenizer=tokenizer,
        vae_transform=vae_transform,
        vit_transform=vit_transform,
        new_token_ids=new_token_ids,
    )


def save_output(result: dict, task: str, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    if task in {"text-to-image", "t2i", "edit"}:
        image = result.get("image")
        if image is None:
            raise RuntimeError("inferencer did not return an image")
        image.save(output_path)
        text = result.get("text")
        if text:
            text_path = output_path.with_suffix(output_path.suffix + ".txt")
            text_path.write_text(text, encoding="utf-8")
            print(f"thinking_output={text_path}")
    elif task in {"understand", "understanding"}:
        text = result.get("text")
        if text is None:
            raise RuntimeError("inferencer did not return text")
        output_path.write_text(text, encoding="utf-8")
    else:
        raise ValueError(f"unsupported task: {task}")


def run(args: argparse.Namespace) -> None:
    set_seed(args.seed)
    output_path = Path(args.output)

    print(f"task={args.task}")
    print(f"prompt={args.prompt}")
    print(f"input_image={args.image or ''}")
    print(f"output={output_path}")
    print(f"model_path={args.model_path}")
    print(f"mode={args.mode}")
    print(f"seed={args.seed}")
    print(f"think={args.think}")
    print(f"num_timesteps={args.num_timesteps}")
    print(f"cfg_text_scale={args.cfg_text_scale}")
    print(f"cfg_img_scale={args.cfg_img_scale}")
    print(f"cfg_interval={args.cfg_interval}")
    print(f"timestep_shift={args.timestep_shift}")
    print("gpu_memory_before=" + gpu_memory_summary())

    start = time.perf_counter()
    inferencer = build_inferencer(args.model_path, args.mode)
    print(f"model_load_seconds={time.perf_counter() - start:.2f}")
    print("gpu_memory_after_load=" + gpu_memory_summary())

    image = None
    if args.image:
        image = pil_img2rgb(Image.open(args.image))

    inference_hyper = dict(
        max_think_token_n=args.max_think_token_n,
        do_sample=args.do_sample,
        text_temperature=args.text_temperature,
        cfg_text_scale=args.cfg_text_scale,
        cfg_img_scale=args.cfg_img_scale,
        cfg_interval=args.cfg_interval,
        timestep_shift=args.timestep_shift,
        num_timesteps=args.num_timesteps,
        cfg_renorm_min=args.cfg_renorm_min,
        cfg_renorm_type=args.cfg_renorm_type,
        image_shapes=args.image_shape,
    )

    task_start = time.perf_counter()
    if args.task in {"text-to-image", "t2i"}:
        result = inferencer(text=args.prompt, think=args.think, **inference_hyper)
    elif args.task in {"understand", "understanding"}:
        if image is None:
            raise ValueError("--image is required for understanding")
        result = inferencer(
            image=image,
            text=args.prompt,
            think=args.think,
            understanding_output=True,
            **inference_hyper,
        )
    elif args.task == "edit":
        if image is None:
            raise ValueError("--image is required for editing")
        result = inferencer(image=image, text=args.prompt, think=args.think, **inference_hyper)
    else:
        raise ValueError(f"unsupported task: {args.task}")

    print(f"inference_seconds={time.perf_counter() - task_start:.2f}")
    save_output(result, args.task, output_path)
    print(f"total_seconds={time.perf_counter() - start:.2f}")
    print("gpu_memory_after_inference=" + gpu_memory_summary())
    print("status=success")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run BAGEL inference without Gradio.")
    parser.add_argument("--model_path", default="models/BAGEL-7B-MoT")
    parser.add_argument("--mode", type=int, default=2, choices=[1, 2, 3])
    parser.add_argument("--task", required=True, choices=["text-to-image", "t2i", "understand", "understanding", "edit"])
    parser.add_argument("--image", default=None)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--think", type=str2bool, nargs="?", const=True, default=False)
    parser.add_argument("--num_timesteps", type=int, default=50)
    parser.add_argument("--cfg_text_scale", type=float, default=4.0)
    parser.add_argument("--cfg_img_scale", type=float, default=2.0)
    parser.add_argument("--cfg_interval", type=parse_cfg_interval, default=[0.4, 1.0])
    parser.add_argument("--timestep_shift", type=float, default=3.0)
    parser.add_argument("--cfg_renorm_min", type=float, default=0.0)
    parser.add_argument("--cfg_renorm_type", default="global", choices=["global", "local", "text_channel"])
    parser.add_argument("--image_shape", type=parse_image_shape, default=(1024, 1024))
    parser.add_argument("--max_think_token_n", type=int, default=512)
    parser.add_argument("--do_sample", type=str2bool, nargs="?", const=True, default=False)
    parser.add_argument("--text_temperature", type=float, default=0.3)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    run(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
