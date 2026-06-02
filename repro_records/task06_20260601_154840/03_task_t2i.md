# Task 6: Text-to-Image Baseline

## 目标

运行一次固定参数的 BAGEL 文生图 baseline。

固定参数：

- `prompt`: `a small robot sitting at a wooden desk, reading a book under warm light, highly detailed`
- `seed`: `42`
- `num_timesteps`: `30`
- `cfg_text_scale`: `4.0`
- `mode`: `2`

输出目标：

- `repro_records/task06_20260601_154840/outputs/t2i_baseline.png`

## 执行命令

完整命令记录：

- `repro_records/task06_20260601_154840/commands.sh`

核心运行命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py \
  --model_path models/BAGEL-7B-MoT \
  --mode 2 \
  --task text-to-image \
  --prompt "a small robot sitting at a wooden desk, reading a book under warm light, highly detailed" \
  --output repro_records/task06_20260601_154840/outputs/t2i_baseline.png \
  --seed 42 \
  --think false \
  --num_timesteps 30 \
  --cfg_text_scale 4.0 \
  --cfg_img_scale 1.5 \
  --cfg_interval 0.4 \
  --timestep_shift 3.0
```

原始日志：

- `repro_records/task06_20260601_154840/logs/t2i_baseline.log`

## 关键输出

### 输出文件

生成图片：

- `repro_records/task06_20260601_154840/outputs/t2i_baseline.png`

文件检查：

```text
t2i_baseline.png: PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
```

文件大小：

```text
930K
```

像素统计：

```text
{'size': (1024, 1024), 'mode': 'RGB', 'mean': [90.72, 71.74, 54.57], 'extrema': ((0, 255), (0, 255), (0, 255))}
```

说明图片不是空白输出，RGB 通道存在完整动态范围。

### 运行状态

日志关键字段：

```text
task=text-to-image
prompt=a small robot sitting at a wooden desk, reading a book under warm light, highly detailed
output=repro_records/task06_20260601_154840/outputs/t2i_baseline.png
mode=2
seed=42
think=False
num_timesteps=30
cfg_text_scale=4.0
cfg_img_scale=1.5
cfg_interval=[0.4, 1.0]
timestep_shift=3.0
status=success
```

### 运行时间

脚本内部记录：

```text
model_load_seconds=24.71
inference_seconds=136.75
total_seconds=162.26
```

外层命令记录：

```text
task6 exit_status=0 runtime_seconds=170
```

差异来自 conda run 启动、shell 包装和日志收尾开销。

### GPU 显存

推理前：

```text
nvidia_smi=0, 4, 24564 | 1, 672, 24564
```

模型加载后：

```text
nvidia_smi=0, 4052, 24564 | 1, 4140, 24564
```

推理后、进程退出前脚本记录：

```text
nvidia_smi=0, 4412, 24564 | 1, 4156, 24564
```

PyTorch 峰值显存：

```text
cuda:0 torch_peak=11.27GiB
cuda:1 torch_peak=12.36GiB
```

任务结束后再次检查：

```text
Processes: No running processes found
GPU 0: 1MiB / 24564MiB
GPU 1: 672MiB / 24564MiB
```

说明 Task 6 结束后没有残留 BAGEL 推理进程。

## 报错 / 警告

没有 Python traceback、CUDA OOM 或任务失败。

日志中有以下警告：

```text
Some parameters are on the meta device because they were offloaded to the cpu.
```

分析：

- 该信息来自 accelerate / bitsandbytes 的模型加载与 CPU offload 流程。
- 本次使用 `mode=2` NF4 低显存模式，部分参数 offload 到 CPU 属于预期行为。
- 任务最终 `status=success`，输出图片已保存，因此该警告未阻断实验。

## 修复尝试

无。

本任务没有修改代码，没有修改模型结构、forward 逻辑、tokenizer、VAE、ViT 或 checkpoint 加载逻辑。

## 结果

Task 6 成功完成。

实际完成内容：

- 使用 Task 5 创建的 `scripts/run_bagel_minimal.py` 执行一次文生图 baseline。
- 使用 `mode=2`、`seed=42`、`num_timesteps=30`、`cfg_text_scale=4.0`。
- 成功生成 1024x1024 RGB PNG 图片。
- 记录了运行时间、GPU 显存、日志和输出文件路径。

未验证内容：

- 没有人工评价图像质量。
- 没有与其他 seed / CFG / timesteps 对比。
- 没有运行 thinking mode。

## 可用于 PPT 的记录

- 文生图 baseline 已成功跑通。
- 输入 prompt：小机器人坐在木桌前，在暖光下读书，高细节。
- 参数：`seed=42`、`num_timesteps=30`、`cfg_text_scale=4.0`、`mode=2`。
- 输出：`t2i_baseline.png`，1024x1024 RGB PNG。
- 模型加载约 24.71 秒，图像推理约 136.75 秒，总耗时约 162.26 秒。
- PyTorch 峰值显存：GPU0 约 11.27GiB，GPU1 约 12.36GiB。
- 任务完成后无残留推理进程。
- 本结果证明最小 CLI 可以支持实际文生图生成，不仅是图像理解 smoke test。
