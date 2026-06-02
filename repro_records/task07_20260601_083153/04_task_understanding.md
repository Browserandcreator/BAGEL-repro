# Task 7：Image Understanding Baseline

## 目标

运行一次 BAGEL 图像理解基线任务，验证 `scripts/run_bagel_minimal.py` 能绕过 Gradio 对本地图片进行描述生成。

## 执行命令

本任务按要求先读取了 `docs/codex_bagel_repro_plan.md`，随后查找本地图片、记录输入图片信息、记录 GPU 状态，并执行一次 understanding 推理。

关键命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task understand --image test_images/meme.jpg --prompt "Describe this image in detail." --output repro_records/task07_20260601_083153/outputs/understanding_baseline.txt --mode 2
```

完整命令记录见：

```text
repro_records/task07_20260601_083153/commands.sh
```

## 关键输出

输入图片：

```text
test_images/meme.jpg
```

输出文本：

```text
repro_records/task07_20260601_083153/outputs/understanding_baseline.txt
```

模型生成内容摘要：

- 识别出图片是三段式拼图。
- 识别到 “First two pages / Middle pages / Last two pages” 的结构。
- 描述了手写内容从可读到难以辨认，再到类似 ECG 曲线的变化。
- 判断该图具有幽默效果，表达考试过程中字迹逐渐恶化的梗。

运行日志中的关键指标：

```text
task=understand
input_image=test_images/meme.jpg
output=repro_records/task07_20260601_083153/outputs/understanding_baseline.txt
model_path=models/BAGEL-7B-MoT
mode=2
seed=0
think=False
model_load_seconds=24.01
inference_seconds=148.33
total_seconds=172.41
status=success
```

显存记录：

```text
运行前：
GPU 0: 1 MiB / 24564 MiB
GPU 1: 672 MiB / 24564 MiB

运行中：
GPU 0: 4296 MiB / 24564 MiB
GPU 1: 4176 MiB / 24564 MiB

CLI 记录的推理后峰值：
cuda:0 torch_peak=11.27GiB
cuda:1 torch_peak=12.36GiB

运行后：
GPU 0: 1 MiB / 24564 MiB
GPU 1: 672 MiB / 24564 MiB
```

## 报错 / 警告

1. 默认 Python 环境缺少依赖：

```text
ModuleNotFoundError: No module named 'accelerate'
```

原因分析：默认 `python` 指向 `/root/miniconda3/bin/python`，不是实际安装 BAGEL 依赖的 `bagel` conda 环境。

处理方式：改用已有环境：

```bash
/root/miniconda3/bin/conda run -n bagel python ...
```

2. `/usr/bin/time` 不存在：

```text
/bin/bash: line 2: /usr/bin/time: No such file or directory
```

原因分析：系统没有 `/usr/bin/time` 工具。该问题只影响外部 runtime 记录，不影响 BAGEL 推理。CLI 自身已打印 `model_load_seconds`、`inference_seconds` 和 `total_seconds`。

3. safetensors metadata 警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata.
Defaulting to 'pt' metadata.
```

含义：权重文件缺少 safetensors metadata，加载器回退到 `pt` metadata。该警告未导致任务失败。

4. CPU offload 提示：

```text
Some parameters are on the meta device because they were offloaded to the cpu.
```

含义：`mode=2` 低显存模式下有参数被 offload 到 CPU，符合低显存加载策略。

## 修复尝试

没有修改任何 BAGEL 模型代码、推理逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务只做了低风险运行方式调整：

- 从默认 Python 切换到已有 `bagel` conda 环境。
- 去掉不存在的 `/usr/bin/time`，改用 CLI 内置 runtime 统计。

## 结果

Task 7 成功完成。

实际执行了一次图像理解 baseline：

```text
task=understand
image=test_images/meme.jpg
prompt=Describe this image in detail.
mode=2
output=repro_records/task07_20260601_083153/outputs/understanding_baseline.txt
status=success
```

输出文件已生成，且内容与输入图片语义基本一致。

## 可用于 PPT 的记录

- 使用 `scripts/run_bagel_minimal.py` 成功完成 BAGEL 图像理解任务，绕过 Gradio UI 直接调用推理流程。
- 输入为本地图片 `test_images/meme.jpg`，输出为文本描述 `understanding_baseline.txt`。
- `mode=2` 可完成 image understanding，运行中使用两张 RTX 4090，CLI 记录的 torch 显存峰值约为 GPU0 11.27GiB、GPU1 12.36GiB。
- 本次总耗时约 172.41 秒，其中模型加载约 24.01 秒，推理约 148.33 秒。
- 主要工程问题不是模型逻辑错误，而是默认 Python 环境缺少依赖；切换到 `bagel` conda 环境后任务成功。
- `ema.safetensors` 缺少 metadata 和 CPU offload 均为运行警告，未阻断推理。
