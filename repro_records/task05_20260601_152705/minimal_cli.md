# Task 5: Create Minimal CLI Script

## 目标

创建一个绕过 Gradio 的最小命令行脚本，直接调用 BAGEL 推理流程。

目标文件：

- `scripts/run_bagel_minimal.py`

脚本需要支持：

- 文生图：`--task text-to-image` 或 `--task t2i`
- 图像理解：`--task understand` 或 `--task understanding`
- 图像编辑：`--task edit`

本任务允许新增 CLI 包装和日志输出，但不修改 BAGEL 模型结构、forward 逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

## 执行命令

完整命令记录：

- `repro_records/task05_20260601_152705/commands.sh`

主要执行内容：

```bash
sed -n '1,260p' AGENTS.md
sed -n '1,520p' docs/codex_bagel_repro_plan.md
sed -n '1,260p' app.py
sed -n '261,620p' app.py
sed -n '1,360p' inferencer.py
ls -la scripts || true
find . -maxdepth 3 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort | head -100
ls -lah models/BAGEL-7B-MoT || true
nvidia-smi
python -m py_compile scripts/run_bagel_minimal.py
python scripts/run_bagel_minimal.py --help
/root/miniconda3/bin/conda env list
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --model_path models/BAGEL-7B-MoT --mode 2 --task understand --image test_images/meme.jpg --prompt "Describe this image briefly." --output repro_records/task05_20260601_152705/outputs/smoke_understanding.txt --seed 42 --think false --max_think_token_n 64
ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
netstat -ltnp 2>/dev/null | grep ":7860" || true
```

原始 smoke test 日志：

- `repro_records/task05_20260601_152705/logs/minimal_cli.log`

## 关键输出

### 新增脚本

新增文件：

- `scripts/run_bagel_minimal.py`

脚本复用了 `app.py` 中的主要加载逻辑：

- 读取 `llm_config.json`
- 读取 `vit_config.json`
- 调用 `load_ae()` 加载 VAE
- 创建 `BagelConfig`
- 使用 `init_empty_weights()` 初始化 `Qwen2ForCausalLM`、`SiglipVisionModel` 和 `Bagel`
- 加载 tokenizer 并调用 `add_special_tokens()`
- 创建 `ImageTransform`
- 调用 `infer_auto_device_map()`
- 根据 `--mode` 选择：
  - `mode=1`: `load_checkpoint_and_dispatch()`
  - `mode=2`: NF4 `load_and_quantize_model()`
  - `mode=3`: INT8 `load_and_quantize_model()`
- 创建 `InterleaveInferencer`

脚本支持的关键参数：

- `--model_path`
- `--mode`
- `--task`
- `--image`
- `--prompt`
- `--output`
- `--seed`
- `--think`
- `--num_timesteps`
- `--cfg_text_scale`
- `--cfg_img_scale`
- `--cfg_interval`
- `--timestep_shift`

额外提供：

- `--cfg_renorm_min`
- `--cfg_renorm_type`
- `--image_shape`
- `--max_think_token_n`
- `--do_sample`
- `--text_temperature`

### Smoke test

本任务只运行了一次 smoke test，选择图像理解任务，原因是它能验证模型加载、图像输入、文本输出和文件保存，同时比文生图/编辑更轻。

命令：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py \
  --model_path models/BAGEL-7B-MoT \
  --mode 2 \
  --task understand \
  --image test_images/meme.jpg \
  --prompt "Describe this image briefly." \
  --output repro_records/task05_20260601_152705/outputs/smoke_understanding.txt \
  --seed 42 \
  --think false \
  --max_think_token_n 64
```

输出文件：

- `repro_records/task05_20260601_152705/outputs/smoke_understanding.txt`

输出开头：

```text
The image is a humorous meme titled "My Handwriting In Exams," which illustrates the progression of handwriting quality during an exam.
```

### 运行时间与 GPU 显存

日志记录：

```text
model_load_seconds=24.65
inference_seconds=46.10
total_seconds=70.82
status=success
```

GPU 显存记录：

```text
gpu_memory_before=... nvidia_smi=0, 4, 24564 | 1, 672, 24564
gpu_memory_after_load=... nvidia_smi=0, 4052, 24564 | 1, 4140, 24564
gpu_memory_after_inference=... nvidia_smi=0, 5206, 24564 | 1, 4176, 24564
```

外层命令记录的总耗时：

```text
smoke test exit_status=0 runtime_seconds=78
```

smoke test 结束后再次检查：

```text
Processes: No running processes found
```

说明本次 CLI 进程已退出，没有继续占用 GPU 进程。

### WebUI 进程检查

用户提醒之前 WebUI 可能未关闭后，已检查：

- `ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true`
- `netstat -ltnp 2>/dev/null | grep ":7860" || true`
- `nvidia-smi`

结果：

- 未发现 `app.py` WebUI 进程。
- 未发现 `run_bagel_minimal.py` 残留进程。
- `7860` 端口无监听输出。
- `nvidia-smi` 显示没有活跃 GPU 计算进程。

因此没有执行 kill 操作。

## 报错 / 警告

### 默认 Python 环境缺少依赖

执行：

```bash
python scripts/run_bagel_minimal.py --help
```

失败：

```text
ModuleNotFoundError: No module named 'accelerate'
```

分析：

- 这是环境问题，不是脚本语法问题。
- 系统默认 `python` 环境缺少 `accelerate`。
- 项目可用环境是 conda 环境 `bagel`。

验证：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
```

结果成功输出 CLI help。

### 工具缺失

检查 WebUI 进程时：

```text
lsof: command not found
ss: command not found
```

分析：

- 当前环境未安装 `lsof` 和 `ss`。
- 已使用 `ps`、`netstat` 和 `nvidia-smi` 进行替代检查。

## 修复尝试

新增低风险 CLI 包装脚本：

- `scripts/run_bagel_minimal.py`

脚本层面做了以下工程处理：

- 在脚本开头将仓库根目录加入 `sys.path`，避免从 `scripts/` 子目录运行时无法导入仓库模块。
- 添加 `set_seed()`，复用 `app.py` 的随机种子策略。
- 添加 `gpu_memory_summary()`，记录 PyTorch 显存和 `nvidia-smi` 显存。
- 添加输出保存逻辑：
  - 图像任务保存图片。
  - 图像理解保存文本。
  - thinking 文本如存在则保存到同名附加 `.txt` 文件。
- 添加运行时间记录：
  - 模型加载时间。
  - 推理时间。
  - 总时间。

没有修改核心模型逻辑。

## 结果

Task 5 完成。

已创建：

- `scripts/run_bagel_minimal.py`

已验证：

- `python -m py_compile scripts/run_bagel_minimal.py` 成功。
- `conda run -n bagel python scripts/run_bagel_minimal.py --help` 成功。
- 使用 `mode=2`、`task=understand`、`test_images/meme.jpg` 的一次 smoke test 成功。
- 输出文本已保存到 `repro_records/task05_20260601_152705/outputs/smoke_understanding.txt`。

未验证：

- 文生图实际输出。
- 图像编辑实际输出。
- `mode=1` 和 `mode=3`。
- thinking mode 的实际输出质量。

## 可用于 PPT 的记录

- 新增最小 CLI：`scripts/run_bagel_minimal.py`，可绕过 Gradio 直接调用 BAGEL 推理。
- CLI 复用官方 `app.py` 的模型加载、tokenizer、VAE transform、ViT transform 和 `InterleaveInferencer` 初始化逻辑。
- CLI 支持文生图、图像理解、图像编辑三类任务。
- 本次 smoke test 选择图像理解任务，输入 `test_images/meme.jpg`，输出文本保存成功。
- `mode=2` NF4 加载成功；模型加载约 24.65 秒，推理约 46.10 秒，总耗时约 70.82 秒。
- GPU 峰值 PyTorch 显存记录：GPU0 约 11.27GiB，GPU1 约 12.36GiB。
- 默认系统 Python 缺少 `accelerate`，需要使用 `conda run -n bagel python ...`。
- smoke test 后无残留 WebUI/CLI 进程，`7860` 端口未发现监听。
