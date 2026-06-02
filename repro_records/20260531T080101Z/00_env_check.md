# Task 0：环境检查

## 目标

检查 BAGEL 复现环境中的 Python、CUDA、PyTorch、`flash-attn`、GPU、磁盘空间和仓库状态。

## 执行命令

- `pwd`
- `git rev-parse HEAD`
- `git status --short`
- `/root/miniconda3/bin/conda run -n bagel python -V`
- `/root/miniconda3/bin/conda run -n bagel which python`
- `/root/miniconda3/bin/conda run -n bagel pip list | grep -E 'torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors|huggingface'`
- `nvidia-smi`
- `df -h`
- `du -sh .`
- `/root/miniconda3/bin/conda env list`
- `/root/miniconda3/bin/conda list -n bagel | grep -E 'torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors'`
- `/root/miniconda3/bin/conda run -n bagel python -c 'import torch; ...'`

完整命令记录已保存到 `commands.sh`。

## 关键输出

- 仓库路径：`/root/autodl-tmp/BAGEL`
- Git 提交：`a2fa77dd8caeefc41e6607ae0ec17408d3f4ee9f`
- Git 状态存在未跟踪的本地路径：`AGENTS.md`、`docs/`、`models/`、`repro_records/`、`scripts_local/`
- Python 版本：`3.10.20`
- Python 路径：`/root/miniconda3/envs/bagel/bin/python`
- PyTorch 版本：`2.5.1+cu124`
- PyTorch CUDA 构建版本：`12.4`
- `torch.cuda.is_available()`: `True`
- PyTorch 可见 GPU 数量：`2`
- GPU 0：`NVIDIA GeForce RTX 4090`，25252724736 bytes VRAM
- GPU 1：`NVIDIA GeForce RTX 4090`，25252724736 bytes VRAM
- `nvidia-smi` 驱动版本：`595.58.03`
- `nvidia-smi` 显示 CUDA 版本：`13.2`
- 检查时 GPU 显存占用：两张 RTX 4090 均为 `1MiB / 24564MiB`
- 关键包版本：
  - `accelerate 1.13.0`
  - `bitsandbytes 0.49.2`
  - `flash_attn` / `flash-attn 2.5.8`
  - `gradio 5.38.2`
  - `huggingface-hub 0.29.1`
  - `safetensors 0.4.5`
  - `torch 2.5.1`
  - `torchvision 0.20.1`
  - `transformers 4.49.0`
- 仓库目录大小：`11G`
- 根文件系统：总量 `30G`，已用 `27G`，可用 `4.0G`，使用率 `87%`
- `/autodl-pub`：总量 `7.0T`，已用 `6.7T`，可用 `354G`，使用率 `96%`

## 错误 / 警告

- 最初尝试读取 `/root/AGENTS.md` 和 `/root/docs/codex_bagel_repro_plan.md` 失败，因为实际项目目录位于 `/root/autodl-tmp/BAGEL`。
- 初始沙箱执行失败，报错为 `bwrap: No permissions to create a new namespace`；随后使用已批准的提权执行方式继续完成只读检查。
- 磁盘空间存在风险：根文件系统仅剩 `4.0G` 可用，`/autodl-pub` 使用率为 `96%`。
- Git 工作区不是干净状态，存在多个未跟踪路径。本任务未做清理。

## 修复尝试

未修改代码。发现项目实际路径后，将 Task 0 记录目录放到仓库内的 `repro_records/20260531T080101Z/`。

## 结果

从 CUDA / PyTorch 角度看，当前环境可用于继续下一步复现检查：

- `bagel` conda 环境存在。
- Python 从预期的 conda 环境运行。
- PyTorch 可正常导入，并能看到两张 RTX 4090。
- BAGEL UI / 推理所需的高层依赖看起来已安装，包括 `torch`、`flash-attn`、`accelerate`、`transformers`、`gradio`、`bitsandbytes` 和 `safetensors`。

主要剩余风险是磁盘空间和仓库 / 权重完整性，这应在 Task 1 中单独检查。本次未执行 Task 1。

## PPT 可用备注

- 硬件：2x NVIDIA GeForce RTX 4090，每张约 24GB VRAM。
- 软件：Python 3.10.20，PyTorch 2.5.1+cu124，CUDA 可用。
- 环境看起来已具备继续进行仓库和权重检查的基础条件。
- Task 0 未加载模型，未运行推理，未启动 UI。
