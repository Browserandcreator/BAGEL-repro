# Task 8：Image Editing Baseline

## 目标

运行一次 BAGEL 图像编辑基线任务，验证 `scripts/run_bagel_minimal.py` 能绕过 Gradio 对本地图片进行编辑生成。

## 执行命令

本任务先读取 `docs/codex_bagel_repro_plan.md`，随后查找本地图片、记录输入图片信息、记录 GPU 状态，并执行一次 image editing 推理。

关键命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task edit --image test_images/women.jpg --prompt "change the background into a subway station while keeping the main subject unchanged" --output repro_records/task08_20260601_085406/outputs/edit_baseline.png --mode 2 --num_timesteps 30 --cfg_text_scale 4.0 --cfg_img_scale 2.0 --seed 42
```

完整命令记录见：

```text
repro_records/task08_20260601_085406/commands.sh
```

## 关键输出

输入图片：

```text
test_images/women.jpg
```

输出图片：

```text
repro_records/task08_20260601_085406/outputs/edit_baseline.png
```

输出文件信息：

```text
PNG image data, 800 x 1024, 8-bit/color RGB, non-interlaced
```

运行日志中的关键指标：

```text
task=edit
prompt=change the background into a subway station while keeping the main subject unchanged
input_image=test_images/women.jpg
output=repro_records/task08_20260601_085406/outputs/edit_baseline.png
model_path=models/BAGEL-7B-MoT
mode=2
seed=42
think=False
num_timesteps=30
cfg_text_scale=4.0
cfg_img_scale=2.0
model_load_seconds=25.81
inference_seconds=133.53
total_seconds=159.98
status=success
```

显存记录：

```text
运行前：
GPU 0: 1 MiB / 24564 MiB
GPU 1: 672 MiB / 24564 MiB

CLI 记录的推理后峰值：
cuda:0 torch_peak=11.27GiB
cuda:1 torch_peak=12.36GiB

运行后：
GPU 0: 1 MiB / 24564 MiB
GPU 1: 672 MiB / 24564 MiB
```

## 报错 / 警告

1. safetensors metadata 警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata.
Defaulting to 'pt' metadata.
```

含义：权重文件缺少 safetensors metadata，加载器回退到 `pt` metadata。该警告未导致任务失败。

2. CPU offload 提示：

```text
Some parameters are on the meta device because they were offloaded to the cpu.
```

含义：`mode=2` 低显存模式下有参数被 offload 到 CPU，符合低显存加载策略。

## 修复尝试

没有修改 BAGEL 模型代码、推理逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务沿用 Task 7 中验证可用的 `bagel` conda 环境运行，因此没有再次触发默认 Python 缺少依赖的问题。

## 结果

Task 8 成功完成。

实际执行了一次 image editing baseline：

```text
task=edit
image=test_images/women.jpg
prompt=change the background into a subway station while keeping the main subject unchanged
mode=2
num_timesteps=30
cfg_text_scale=4.0
cfg_img_scale=2.0
seed=42
output=repro_records/task08_20260601_085406/outputs/edit_baseline.png
status=success
```

## 可用于 PPT 的记录

- 使用 `scripts/run_bagel_minimal.py` 成功完成 BAGEL 图像编辑任务，绕过 Gradio UI 直接调用推理流程。
- 输入为 `test_images/women.jpg`，输出为 `edit_baseline.png`，图片尺寸为 `800 x 1024`。
- 本次使用 `mode=2`、`num_timesteps=30`、`cfg_text_scale=4.0`、`cfg_img_scale=2.0`、`seed=42`。
- 总耗时约 159.98 秒，其中模型加载约 25.81 秒，推理约 133.53 秒。
- CLI 记录的 torch 显存峰值约为 GPU0 11.27GiB、GPU1 12.36GiB。
- `ema.safetensors` metadata 缺失和 CPU offload 均为警告，未阻断生成。
