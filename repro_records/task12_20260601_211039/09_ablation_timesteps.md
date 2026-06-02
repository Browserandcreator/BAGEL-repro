# Task 12：num_timesteps Ablation

## 目标

观察 `num_timesteps` 对 BAGEL 文生图速度和质量的影响。

固定参数：

```text
prompt = a detailed cyberpunk street at night with neon lights and rain
seed = 42
cfg_text_scale = 4.0
mode = 2
think = false
```

消融参数：

```text
num_timesteps = 10
num_timesteps = 30
num_timesteps = 50
```

说明：根据 `AGENTS.md` 的 GPU 执行策略，Codex 先准备可复现实验脚本，GPU 推理由用户手动运行；本次补充阶段只分析用户已生成的日志和图片，没有启动新的 GPU 推理。

## 执行命令

Codex 准备的手动运行脚本：

```bash
bash repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
```

脚本实际使用的 Python 命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py
```

完整命令记录：

```text
repro_records/task12_20260601_211039/commands.sh
```

完整运行日志：

```text
repro_records/task12_20260601_211039/logs/ablation_timesteps.log
```

## 关键输出

三组输出均已生成：

```text
repro_records/task12_20260601_211039/outputs/steps_10.png
repro_records/task12_20260601_211039/outputs/steps_30.png
repro_records/task12_20260601_211039/outputs/steps_50.png
```

文件大小：

| 输出 | 文件大小 |
| --- | ---: |
| `steps_10.png` | 1,595,664 bytes |
| `steps_30.png` | 1,794,554 bytes |
| `steps_50.png` | 1,817,550 bytes |

运行状态：三组均 `status=success`，整体日志末尾为 `status=completed`。

运行时间记录：

| num_timesteps | model_load_seconds | inference_seconds | total_seconds | wall_seconds |
| ---: | ---: | ---: | ---: | ---: |
| 10 | 24.23 | 51.81 | 76.73 | 84 |
| 30 | 24.19 | 131.50 | 156.29 | 163 |
| 50 | 24.79 | 217.11 | 242.63 | 251 |

GPU / 显存记录：

- 运行前日志记录：GPU 0 约 `1 MiB`，GPU 1 约 `672 MiB`，无运行中进程。
- 模型加载后：`nvidia_smi=0, 4052, 24564 | 1, 4140, 24564`。
- 推理后：`nvidia_smi=0, 4412, 24564 | 1, 4156, 24564`。
- PyTorch 峰值记录：GPU 0 `torch_peak=11.27GiB`，GPU 1 `torch_peak=12.36GiB`。
- 任务结束后日志显示无运行中 GPU 进程。

视觉观察：

- `steps_10.png`：街道透视、雨夜氛围、霓虹灯和地面反光已经成立，但整体更雾化，局部纹理有颗粒感，店招文字和建筑细节更不稳定。
- `steps_30.png`：建筑边缘、路面反光、电线和招牌布局更清楚，整体构图比 10 步更稳定，是本次三组中速度和质量较均衡的一档。
- `steps_50.png`：继续增加细节和远处车辆，线缆、招牌、道路反光更丰富；但招牌文字仍有伪字符，主体构图相对 30 步没有发生质变。

## 报错 / 警告

推理日志中的主要警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata. Make sure to save your model with the save_pretrained method. Defaulting to pt metadata.
Some parameters are on the meta device because they were offloaded to the cpu.
```

解释：

- `safetensors` metadata 警告表示权重文件缺少保存元信息，加载器回退为默认 `pt` metadata；本次三组推理均成功完成。
- `meta device` / CPU offload 信息来自 `accelerate` 的分配和量化加载流程，符合 `mode=2` 低显存运行场景，没有导致失败。

本次补充分析未运行新的 GPU 推理，没有新增 CUDA OOM、Python traceback 或模型执行错误。

## 修复尝试

未修改 BAGEL 核心模型逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务只新增和更新 task12 记录文件：

```text
repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
repro_records/task12_20260601_211039/09_ablation_timesteps.md
repro_records/task12_20260601_211039/commands.sh
repro_records/task12_20260601_211039/logs/ablation_timesteps.log
```

本次补充阶段的主要修复是记录修复：把旧报告中“当前阶段尚未生成图片”的占位结论更新为基于已生成日志和图片的最终实验结论。

## 结果

Task 12 已完成生成和记录。

已验证事实：

- 三个 `num_timesteps` 设置均成功运行。
- 三张目标图片均已生成。
- 日志包含每组运行时间、GPU 显存、模型加载和推理耗时。
- 推理耗时随步数显著增加：10 步约 `51.81s`，30 步约 `131.50s`，50 步约 `217.11s`。
- 从 10 步到 30 步，画面稳定性和细节有明显提升；从 30 步到 50 步，细节继续增加，但边际收益小于耗时增长。
- 当前没有残留 BAGEL 推理进程，日志显示任务结束后 GPU 回到空闲状态。

限制：

- 本任务只使用一个 prompt 和一个 seed，不能代表所有场景下的稳定规律。
- 视觉判断基于本次三张输出图的人工观察，属于单样本结论。

## 可用于 PPT 的记录

- Task12 完成 `num_timesteps=10 / 30 / 50` 三档文生图消融。
- 固定 prompt、seed、文本 CFG、低显存模式和 thinking 关闭状态，只改变采样步数。
- 三组均成功生成图片，输出路径完整可复查。
- 运行时间：10 步 total 约 `77s`，30 步 total 约 `156s`，50 步 total 约 `243s`。
- 显存峰值：PyTorch 记录 GPU 0 约 `11.27GiB`，GPU 1 约 `12.36GiB`。
- 质量观察：10 步已经有完整构图但细节粗糙；30 步明显提升稳定性；50 步增加细节但相对 30 步边际收益变小。
- 工程结论：在本 prompt 下，30 步是更均衡的速度/质量折中；50 步适合追求额外细节但耗时明显增加。
