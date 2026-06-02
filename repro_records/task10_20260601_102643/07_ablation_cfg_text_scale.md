# Task 10：CFG Text Scale Ablation

## 目标

观察 `cfg_text_scale` 对 BAGEL 文生图结果的影响。

固定参数：

```text
prompt = a blue glass castle floating above the ocean at sunset
seed = 42
num_timesteps = 30
mode = 2
think = false
```

消融参数：

```text
cfg_text_scale = 1.0
cfg_text_scale = 4.0
cfg_text_scale = 8.0
```

## 执行命令

本任务先由 Codex 准备脚本，随后由用户手动运行：

```bash
bash repro_records/task10_20260601_102643/run_task10_cfg_text_ablation.sh
```

脚本实际使用的 Python 命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py
```

完整命令记录保存在：

```text
repro_records/task10_20260601_102643/commands.sh
```

运行日志保存在：

```text
repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
```

## 关键输出

三组输出均已生成，格式均为 `1024 x 1024` RGB PNG：

```text
repro_records/task10_20260601_102643/outputs/cfg_text_1.png  1.4M
repro_records/task10_20260601_102643/outputs/cfg_text_4.png  1.5M
repro_records/task10_20260601_102643/outputs/cfg_text_8.png  1.6M
```

`file` 检查结果：

```text
cfg_text_1.png: PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
cfg_text_4.png: PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
cfg_text_8.png: PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
```

运行状态：三组均 `status=success`，整体日志末尾为 `status=completed`。

运行时间记录：

| cfg_text_scale | model_load_seconds | inference_seconds | total_seconds | wall_seconds |
| --- | ---: | ---: | ---: | ---: |
| 1.0 | 24.05 | 97.38 | 122.11 | 130 |
| 4.0 | 24.80 | 134.05 | 159.50 | 167 |
| 8.0 | 23.97 | 134.17 | 158.85 | 166 |

GPU / 显存记录：

- 运行前：GPU 0 约 `1 MiB`，GPU 1 约 `672 MiB`，无运行中进程。
- 模型加载后：`nvidia-smi=0, 4052, 24564 | 1, 4140, 24564`。
- 推理后：`nvidia-smi=0, 4412, 24564 | 1, 4156, 24564`。
- PyTorch 峰值记录：GPU 0 `torch_peak=11.27GiB`，GPU 1 `torch_peak=12.36GiB`。
- 任务结束后再次检查：无运行中进程；GPU 0 约 `1 MiB`，GPU 1 约 `672 MiB`。

图片统计信息：

| 输出 | mean_rgb | std_rgb | RGB extrema |
| --- | --- | --- | --- |
| cfg_text_1.png | `(103.71, 112.88, 126.37)` | `(68.09, 51.84, 40.92)` | `R(0,255), G(7,255), B(16,248)` |
| cfg_text_4.png | `(97.43, 104.83, 121.16)` | `(79.37, 47.92, 36.49)` | `R(0,255), G(0,252), B(0,255)` |
| cfg_text_8.png | `(98.56, 107.37, 120.00)` | `(80.83, 51.32, 40.79)` | `R(0,255), G(0,255), B(0,255)` |

从可验证统计看，`cfg_text_scale=4.0` 和 `8.0` 的红色通道标准差高于 `1.0`，文件体积也略大，说明更高 CFG 下图像像素变化和局部对比可能更强。但当前工具无法直接显示图片，因此不能仅凭统计断言具体视觉质量。

## 报错 / 警告

原始推理日志中的警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata. Make sure to save your model with the save_pretrained method. Defaulting to pt metadata.
Some parameters are on the meta device because they were offloaded to the cpu.
```

解释：

- `safetensors` metadata 警告表示权重文件缺少保存元信息，加载器回退为默认 `pt` metadata；本次三组推理仍成功完成。
- `meta device` / CPU offload 信息来自 `accelerate` 的分配和量化加载流程，表示部分参数被 offload；在 mode 2 低显存量化运行中属于可解释现象，本次没有导致失败。

Codex 继续分析阶段遇到的环境问题：

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces.
```

解释：当前 sandbox/user namespace 限制导致部分只读命令或 `view_image` 无法执行。为避免误判图片内容，本报告没有写入直接目视结论。

补充统计时还出现过两次命令拼接错误：

- 一次 heredoc 嵌套错误导致 `EOF: command not found`。
- 一次 `python -c` 换行转义错误导致 `SyntaxError: unexpected character after line continuation character`。

这两个错误只发生在后处理统计命令中，不影响模型推理结果、不影响三张图片文件。之后改用单独 Python heredoc 读取图片统计，已成功。

## 修复尝试

未修改 BAGEL 核心模型逻辑。

本任务中只做了低风险记录和脚本准备：

```text
repro_records/task10_20260601_102643/run_task10_cfg_text_ablation.sh
repro_records/task10_20260601_102643/07_ablation_cfg_text_scale.md
repro_records/task10_20260601_102643/commands.sh
repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
```

为便于手动运行，脚本默认优先使用：

```bash
/root/miniconda3/bin/conda run -n bagel python
```

## 结果

Task 10 已完成生成和记录。

已验证事实：

- 三个 `cfg_text_scale` 设置均成功运行。
- 三张目标图片均已生成。
- 输出分辨率均为 `1024 x 1024`。
- 日志包含每组运行时间、GPU 显存、模型加载和推理耗时。
- `cfg_text_scale=1.0` 的推理耗时约 `97.38s`，明显短于 `4.0` 和 `8.0` 的约 `134s`；这可能与 CFG 强度或内部路径触发有关，但仅凭本次单样本不能下结论。
- `cfg_text_scale=4.0` 与 `8.0` 的耗时和显存表现接近。

视觉分析限制：

- 当前 Codex 工具无法直接打开图片，`view_image` 被 sandbox namespace 限制阻断。
- 因此本报告不声称哪一张“更好看”或“更符合 prompt”。
- 建议人工目视比较以下维度后补充最终视觉结论：是否出现蓝色玻璃城堡、是否漂浮在海面上、是否有日落、构图稳定性、细节清晰度、过强 CFG 是否产生边缘伪影或颜色过饱和。

## 可用于 PPT 的记录

- 本任务完成了 `cfg_text_scale` 的三档消融：`1.0 / 4.0 / 8.0`。
- 固定 prompt、seed、步数、量化模式和 thinking 设置，只改变文本 CFG 强度。
- 三组均生成 `1024 x 1024` 图片，输出路径完整可复查。
- 运行时间：`1.0` 约 `122s` total，`4.0` 约 `160s` total，`8.0` 约 `159s` total。
- 显存峰值：PyTorch 记录 GPU 0 约 `11.27GiB`，GPU 1 约 `12.36GiB`。
- 工程观察：低显存 mode 2 可完成三组文生图消融；权重 metadata 和 CPU offload 有警告但不阻断运行。
- 待补充：人工目视评估三张图的 prompt 遵循度、细节质量和高 CFG 可能带来的伪影。
