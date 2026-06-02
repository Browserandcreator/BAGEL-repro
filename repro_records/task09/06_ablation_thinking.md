# Task 9：Thinking Ablation

## 目标

比较 `think=False` 和 `think=True` 对 BAGEL text-to-image 生成流程的影响，固定 prompt、seed、步数和 CFG 参数，只改变 thinking mode。

## 执行命令

本任务先读取 `docs/codex_bagel_repro_plan.md`，记录运行前 GPU 状态，并分别执行两次 text-to-image 推理。

固定参数：

```text
prompt=a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby
seed=42
num_timesteps=30
cfg_text_scale=4.0
mode=2
```

`think=False` 命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task text-to-image --prompt "a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby" --output repro_records/task09/outputs/think_false.png --mode 2 --seed 42 --num_timesteps 30 --cfg_text_scale 4.0 --think false
```

`think=True` 命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task text-to-image --prompt "a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby" --output repro_records/task09/outputs/think_true.png --mode 2 --seed 42 --num_timesteps 30 --cfg_text_scale 4.0 --think true
```

完整命令记录见：

```text
repro_records/task09/commands.sh
```

## 关键输出

生成文件：

```text
repro_records/task09/outputs/think_false.png
repro_records/task09/outputs/think_true.png
repro_records/task09/outputs/think_true_text.txt
```

文件信息：

```text
think_false.png: PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
think_true.png:  PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced
```

`think=False` 运行指标：

```text
status=success
model_load_seconds=24.55
inference_seconds=136.26
total_seconds=161.71
torch_peak cuda:0=11.27GiB
torch_peak cuda:1=12.36GiB
```

`think=True` 运行指标：

```text
status=success
model_load_seconds=25.30
inference_seconds=263.60
total_seconds=289.84
thinking_output=repro_records/task09/outputs/think_true.png.txt
torch_peak cuda:0=11.27GiB
torch_peak cuda:1=12.36GiB
```

Thinking 文本已复制到计划要求的路径：

```text
repro_records/task09/outputs/think_true_text.txt
```

Thinking 文本摘要：模型先将原始 prompt 扩展为更详细的生成描述，包括高科技厨房、机器人厨师、先进烹饪工具、发光显示、机械臂、观察场景的猫、金属反射和整体构图等细节。

## 报错 / 警告

1. `think=True` 第一次启动时，日志包装命令出现 Python 换行转义错误：

```text
SyntaxError: unexpected character after line continuation character
```

原因分析：用于边运行边写日志的临时 Python wrapper 中包含未正确处理的换行转义。该错误发生在 wrapper 解析阶段，模型没有启动，不是 BAGEL 模型错误。

处理方式：改用与 `think=False` 相同的单行 wrapper 重新运行 `think=True`，随后成功。

2. 运行过程中出现 safetensors metadata 警告：

```text
The safetensors archive passed at models/BAGEL-7B-MoT/ema.safetensors does not contain metadata.
Defaulting to 'pt' metadata.
```

含义：权重文件缺少 safetensors metadata，加载器回退到 `pt` metadata。该警告未导致任务失败。

3. 运行过程中出现 CPU offload 提示：

```text
Some parameters are on the meta device because they were offloaded to the cpu.
```

含义：`mode=2` 低显存模式下有参数被 offload 到 CPU，符合低显存加载策略。

4. 当前 sandbox 的图片查看工具无法打开本地图片，报 user namespace 相关错误。因此本报告只确认输出文件、尺寸、日志指标和 thinking 文本内容，未做人工视觉质量判断。

## 修复尝试

没有修改 BAGEL 模型代码、推理逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务只做了低风险记录整理：

- 修正日志包装命令后重跑 `think=True`。
- 将 CLI 自动生成的 `think_true.png.txt` 复制为计划要求的 `think_true_text.txt`。

## 结果

Task 9 成功完成。

两组推理均成功生成图像：

```text
think=False -> repro_records/task09/outputs/think_false.png
think=True  -> repro_records/task09/outputs/think_true.png
```

`think=True` 额外生成了 thinking 文本，并且总耗时明显更长：

```text
think=False total_seconds=161.71
think=True  total_seconds=289.84
```

在本次记录中，`think=True` 比 `think=False` 多约 128.13 秒，总耗时约为 `think=False` 的 1.79 倍。两者的 torch 显存峰值记录相同，均约为 GPU0 11.27GiB、GPU1 12.36GiB。

## 可用于 PPT 的记录

- Thinking ablation 已完成：同一 prompt、seed、步数和 CFG 下分别运行 `think=False` 与 `think=True`。
- `think=True` 会先生成一段文本化思考/扩写 prompt，再进入图像生成流程。
- 本次 `think=True` 的 thinking 文本把原始 prompt 扩展为更细的场景描述，包括高科技厨房、机器人厨师、机械臂、发光显示、猫和构图细节。
- `think=False` 总耗时约 161.71 秒；`think=True` 总耗时约 289.84 秒，约为 1.79 倍。
- 两组输出均为 `1024 x 1024` PNG 图像。
- 两组 torch 显存峰值接近：GPU0 约 11.27GiB，GPU1 约 12.36GiB。
- 当前记录尚未包含人工视觉质量判断，只能确认文件生成、thinking 文本和运行指标。
