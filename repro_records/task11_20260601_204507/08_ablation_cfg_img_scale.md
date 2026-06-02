# Task 11：CFG Image Scale Ablation

## 目标

观察 `cfg_img_scale` 对 BAGEL 图像编辑结果的影响。

固定参数：

```text
image = test_images/women.jpg
prompt = change the background into a snowy mountain while keeping the main subject unchanged
seed = 42
num_timesteps = 30
cfg_text_scale = 4.0
mode = 2
think = false
```

消融参数：

```text
cfg_img_scale = 1.0
cfg_img_scale = 2.0
cfg_img_scale = 4.0
```

根据更新后的 `AGENTS.md`，GPU 推理由用户手动运行，Codex 只准备脚本并在用户运行后整理结果。

## 执行命令

Codex 准备的手动运行脚本：

```bash
bash repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh
```

脚本实际使用的 Python 命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py
```

完整命令记录：

```text
repro_records/task11_20260601_204507/commands.sh
```

完整运行日志：

```text
repro_records/task11_20260601_204507/logs/ablation_cfg_img.log
```

## 关键输出

输入图片：

```text
test_images/women.jpg
JPEG image data, 800x1024, components 3
```

输出图片均已生成，格式均为 `800 x 1024` RGB PNG：

```text
repro_records/task11_20260601_204507/outputs/cfg_img_1.png  943K
repro_records/task11_20260601_204507/outputs/cfg_img_2.png  1.1M
repro_records/task11_20260601_204507/outputs/cfg_img_4.png  1.4M
```

`file` 检查结果：

```text
cfg_img_1.png: PNG image data, 800 x 1024, 8-bit/color RGB, non-interlaced
cfg_img_2.png: PNG image data, 800 x 1024, 8-bit/color RGB, non-interlaced
cfg_img_4.png: PNG image data, 800 x 1024, 8-bit/color RGB, non-interlaced
```

运行状态：三组均 `status=success`，整体日志末尾为 `status=completed`。

运行时间记录：

| cfg_img_scale | model_load_seconds | inference_seconds | total_seconds | wall_seconds |
| --- | ---: | ---: | ---: | ---: |
| 1.0 | 24.04 | 97.44 | 122.10 | 130 |
| 2.0 | 23.83 | 130.21 | 154.67 | 162 |
| 4.0 | 24.04 | 130.30 | 154.82 | 162 |

GPU / 显存记录：

- 运行前日志记录：GPU 0 约 `4 MiB`，GPU 1 约 `672 MiB`。
- 模型加载后：`nvidia_smi=0, 4052, 24564 | 1, 4140, 24564`。
- 推理后：`nvidia_smi=0, 4968, 24564 | 1, 4702, 24564`。
- PyTorch 峰值记录：GPU 0 `torch_peak=11.27GiB`，GPU 1 `torch_peak=12.36GiB`。
- 任务结束后再次检查：无运行中进程；GPU 0 约 `1 MiB`，GPU 1 约 `672 MiB`。

图片统计和与输入图的像素差异：

| 输出 | mean_rgb | std_rgb | mean_abs_diff_from_input | rms_diff |
| --- | --- | --- | --- | ---: |
| cfg_img_1.png | `(182.47, 124.31, 134.65)` | `(50.78, 80.29, 77.70)` | `(32.01, 32.79, 34.59)` | 56.47 |
| cfg_img_2.png | `(179.42, 122.07, 132.26)` | `(53.36, 79.24, 75.73)` | `(32.44, 32.93, 33.71)` | 56.33 |
| cfg_img_4.png | `(165.22, 117.27, 123.56)` | `(52.72, 68.46, 67.28)` | `(35.02, 33.63, 32.25)` | 50.89 |

可验证的量化观察：

- 三组输出文件体积随 `cfg_img_scale` 增大而增大：`943K -> 1.1M -> 1.4M`。
- `cfg_img_scale=1.0` 的推理耗时约 `97.44s`，明显短于 `2.0` 和 `4.0` 的约 `130s`。
- `cfg_img_scale=2.0` 与 `4.0` 的耗时和显存表现基本一致。
- 与输入图的整体像素差异没有随 `cfg_img_scale` 单调增大：`rms_diff` 分别为 `56.47 / 56.33 / 50.89`。这说明单纯全图像素差异不能直接等价于“编辑更强”或“主体保持更好”，需要结合目视分析。

## 报错 / 警告

推理日志中的主要警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata. Make sure to save your model with the save_pretrained method. Defaulting to pt metadata.
Some parameters are on the meta device because they were offloaded to the cpu.
```

解释：

- `safetensors` metadata 警告表示权重文件缺少保存元信息，加载器回退为默认 `pt` metadata；本次三组推理均成功完成。
- `meta device` / CPU offload 信息来自 `accelerate` 的分配和量化加载流程，符合 `mode=2` 低显存运行场景，没有导致失败。

Codex 后处理阶段遇到的环境限制：

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces.
```

该限制导致部分只读命令和 `view_image` 无法执行。因此，当前报告没有写入直接目视结论。

## 修复尝试

未修改 BAGEL 核心模型逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务只新增和更新 task11 记录文件：

```text
repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh
repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md
repro_records/task11_20260601_204507/commands.sh
repro_records/task11_20260601_204507/logs/ablation_cfg_img.log
```

## 结果

Task 11 已完成生成和记录。

已验证事实：

- 三个 `cfg_img_scale` 设置均成功运行。
- 三张目标图片均已生成。
- 输出分辨率均为 `800 x 1024`，与输入图尺寸一致。
- 日志包含每组运行时间、GPU 显存、模型加载和推理耗时。
- `cfg_img_scale=1.0` 的运行时间明显短于 `2.0` 和 `4.0`；仅凭单次实验不能判断这是稳定规律还是实现路径/运行波动导致。
- 当前没有残留 BAGEL 推理进程，GPU 已回到空闲状态。

视觉分析限制：

- 当前工具无法直接打开图片，`view_image` 被 sandbox namespace 限制阻断。
- 因此本报告不声称哪张图“主体保持最好”或“雪山背景最明显”。
- 建议人工目视比较：人物主体是否保持、人物边缘是否破坏、背景是否替换成雪山、原背景残留程度、过高 `cfg_img_scale` 是否导致编辑幅度下降或主体过度锁定。

## 可用于 PPT 的记录

- Task11 完成 `cfg_img_scale=1.0 / 2.0 / 4.0` 三档图像编辑消融。
- 固定输入图、prompt、seed、步数、文本 CFG 和低显存模式，仅改变图像 CFG 强度。
- 三组均成功生成 `800 x 1024` 图片。
- 运行时间：`1.0` total 约 `122s`，`2.0` total 约 `155s`，`4.0` total 约 `155s`。
- 显存峰值：PyTorch 记录 GPU 0 约 `11.27GiB`，GPU 1 约 `12.36GiB`。
- 工程观察：mode 2 可完成 image editing 消融；metadata 和 CPU offload 警告不阻断运行。
- 待人工目视补充：不同 `cfg_img_scale` 对主体保持和雪山背景替换强度的影响。
