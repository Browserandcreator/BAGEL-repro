# Codex BAGEL Reproduction Plan

This file stores the detailed task plan for BAGEL reproduction.

Codex should read this file together with AGENTS.md before running any task.

## General Rule

Run only one task at a time.

After finishing one task, summarize the result and stop for confirmation.

Do not automatically continue to the next task.

## Task 0: Environment Check

Goal: Check Python, CUDA, PyTorch, flash-attn, GPU, disk, and repository status.

Commands:

    pwd
    git rev-parse HEAD
    git status --short
    python -V
    which python
    pip list | grep -E "torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors|huggingface"
    nvidia-smi
    df -h
    du -sh .

If conda is available:

    conda env list
    conda list | grep -E "torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors"

Write outputs to:

    repro_records/<timestamp>/00_env_check.md
    repro_records/<timestamp>/logs/env_check.log

Stop after Task 0.

## Task 1: Repository and Weight Check

Goal: Check repository structure and whether model weights are complete.

Commands:

    ls -lah
    find . -maxdepth 2 -type f | sort | head -200
    ls -lah models || true
    ls -lah models/BAGEL-7B-MoT || true
    find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
    du -sh models/BAGEL-7B-MoT || true

Important files:

    models/BAGEL-7B-MoT/llm_config.json
    models/BAGEL-7B-MoT/vit_config.json
    models/BAGEL-7B-MoT/ae.safetensors
    models/BAGEL-7B-MoT/ema.safetensors

Write outputs to:

    repro_records/<timestamp>/01_repo_and_weights_check.md
    repro_records/<timestamp>/logs/weights_check.log

Stop after Task 1.

## Task 2: Launch Official UI

Goal: Verify whether official Gradio UI can start.

Try low-memory mode first:

    python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh

If mode 2 fails, try:

    python app.py --mode 3 --server_name 0.0.0.0 --server_port 7860 --zh

If GPU memory is enough, try:

    python app.py --mode 1 --server_name 0.0.0.0 --server_port 7860 --zh

Record:

- Whether launch succeeded.
- Which mode was used.
- Loading time.
- GPU memory usage.
- Access URL.
- Warnings.
- Errors.

Write outputs to:

    repro_records/<timestamp>/02_ui_launch.md
    repro_records/<timestamp>/logs/ui_launch.log

Stop after Task 2.

## Task 3: Analyze app.py

Goal: Read app.py and summarize the official UI inference entry points.

Focus on:

- Model initialization.
- Tokenizer loading.
- VAE transform.
- ViT transform.
- InterleaveInferencer initialization.
- text_to_image().
- image_understanding().
- edit_image().
- Parameters such as cfg_text_scale, cfg_img_scale, num_timesteps, and think.

Write output to:

    repro_records/<timestamp>/summary_app_py.md

Stop after Task 3.

## Task 4: Analyze inferencer.py

Goal: Understand BAGEL interleaved inference data flow.

Focus on:

- init_gen_context().
- update_context_text().
- update_context_image().
- gen_text().
- gen_image().
- interleave_inference().
- Difference between understanding_output=True and False.
- Thinking mode.

Write output to:

    repro_records/<timestamp>/summary_inferencer_py.md

Stop after Task 4.

## Task 5: Create Minimal CLI Script

Goal: Create a minimal command-line script that bypasses Gradio and directly calls the BAGEL inference pipeline.

Target file:

    scripts/run_bagel_minimal.py

The script should support:

- text-to-image
- image understanding
- image editing

Required arguments:

    --model_path
    --mode
    --task
    --image
    --prompt
    --output
    --seed
    --think
    --num_timesteps
    --cfg_text_scale
    --cfg_img_scale
    --cfg_interval
    --timestep_shift

Principles:

- Reuse app.py model loading logic as much as possible.
- Do not modify core model code.
- Save all outputs to the specified path.
- Print task, prompt, input image path, output path, mode, seed, runtime, and GPU memory.

Run only one smoke test after creating the script.

Write outputs to:

    repro_records/<timestamp>/minimal_cli.md
    repro_records/<timestamp>/logs/minimal_cli.log

Stop after Task 5.

## Task 6: Text-to-Image Baseline

Goal: Run one fixed text-to-image baseline.

Parameters:

    prompt = a small robot sitting at a wooden desk, reading a book under warm light, highly detailed
    seed = 42
    num_timesteps = 30
    cfg_text_scale = 4.0
    mode = 2

Output:

    repro_records/<timestamp>/outputs/t2i_baseline.png

Write outputs to:

    repro_records/<timestamp>/03_task_t2i.md
    repro_records/<timestamp>/logs/t2i_baseline.log

Stop after Task 6.

## Task 7: Image Understanding Baseline

Goal: Run one image understanding task.

Use an existing example image if available. Otherwise ask the user to provide an image.

Command format:

    python scripts/run_bagel_minimal.py --task understand --image <input_image> --prompt "Describe this image in detail." --output repro_records/<timestamp>/outputs/understanding_baseline.txt --mode 2

Write outputs to:

    repro_records/<timestamp>/04_task_understanding.md
    repro_records/<timestamp>/logs/understanding_baseline.log

Stop after Task 7.

## Task 8: Image Editing Baseline

Goal: Run one image editing task.

Use an existing example image if available. Otherwise ask the user to provide an image.

Command format:

    python scripts/run_bagel_minimal.py --task edit --image <input_image> --prompt "change the background into a subway station while keeping the main subject unchanged" --output repro_records/<timestamp>/outputs/edit_baseline.png --mode 2 --num_timesteps 30 --cfg_text_scale 4.0 --cfg_img_scale 2.0 --seed 42

Write outputs to:

    repro_records/<timestamp>/05_task_editing.md
    repro_records/<timestamp>/logs/edit_baseline.log

Stop after Task 8.

## Task 9: Thinking Ablation

Goal: Compare think=False and think=True.

Fixed parameters:

    prompt = a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby
    seed = 42
    num_timesteps = 30
    cfg_text_scale = 4.0
    mode = 2

Outputs:

    repro_records/<timestamp>/outputs/think_false.png
    repro_records/<timestamp>/outputs/think_true.png
    repro_records/<timestamp>/outputs/think_true_text.txt

Write outputs to:

    repro_records/<timestamp>/06_ablation_thinking.md
    repro_records/<timestamp>/logs/ablation_thinking.log

Stop after Task 9.

## Task 10: CFG Text Scale Ablation

Goal: Observe the effect of cfg_text_scale.

Fixed parameters:

    prompt = a blue glass castle floating above the ocean at sunset
    seed = 42
    num_timesteps = 30
    mode = 2
    think = false

Run:

    cfg_text_scale = 1.0
    cfg_text_scale = 4.0
    cfg_text_scale = 8.0

Outputs:

    repro_records/<timestamp>/outputs/cfg_text_1.png
    repro_records/<timestamp>/outputs/cfg_text_4.png
    repro_records/<timestamp>/outputs/cfg_text_8.png

Write outputs to:

    repro_records/<timestamp>/07_ablation_cfg_text_scale.md
    repro_records/<timestamp>/logs/ablation_cfg_text.log

Stop after Task 10.

## Task 11: CFG Image Scale Ablation

Goal: Observe the effect of cfg_img_scale in image editing.

Fixed parameters:

    image = same input image
    prompt = change the background into a snowy mountain while keeping the main subject unchanged
    seed = 42
    num_timesteps = 30
    cfg_text_scale = 4.0
    mode = 2

Run:

    cfg_img_scale = 1.0
    cfg_img_scale = 2.0
    cfg_img_scale = 4.0

Outputs:

    repro_records/<timestamp>/outputs/cfg_img_1.png
    repro_records/<timestamp>/outputs/cfg_img_2.png
    repro_records/<timestamp>/outputs/cfg_img_4.png

Write outputs to:

    repro_records/<timestamp>/08_ablation_cfg_img_scale.md
    repro_records/<timestamp>/logs/ablation_cfg_img.log

Stop after Task 11.

## Task 12: num_timesteps Ablation

Goal: Observe the speed-quality trade-off of num_timesteps.

Fixed parameters:

    prompt = a detailed cyberpunk street at night with neon lights and rain
    seed = 42
    cfg_text_scale = 4.0
    mode = 2
    think = false

Run:

    num_timesteps = 10
    num_timesteps = 30
    num_timesteps = 50

Outputs:

    repro_records/<timestamp>/outputs/steps_10.png
    repro_records/<timestamp>/outputs/steps_30.png
    repro_records/<timestamp>/outputs/steps_50.png

Write outputs to:

    repro_records/<timestamp>/09_ablation_timesteps.md
    repro_records/<timestamp>/logs/ablation_timesteps.log

Stop after Task 12.

## Task 13: PPT Summary

Goal: Summarize all completed tasks into a PPT-ready engineering reproduction summary.

Write output to:

    repro_records/<timestamp>/summary_for_ppt.md

The summary should include:

- What was run.
- Environment.
- Repository structure.
- Model loading flow.
- Inference data flow.
- Tested tasks.
- Ablation results.
- Bugs and fixes.
- Engineering insights.
- Limitations.
- What to improve next.

Clearly distinguish:

- Actually executed.
- Only inspected from code.
- Failed.
- Fixed.
- Unverified.

Stop after Task 13.
