# Task 1：Repository and Weight Check

## 目标

检查 BAGEL 仓库结构，以及 `models/BAGEL-7B-MoT` 下模型权重文件是否完整。

## 执行命令

完整命令记录见：

- `repro_records/20260531_162431/commands.sh`

主要执行命令：

```bash
pwd
sed -n '1,240p' AGENTS.md
sed -n '1,260p' docs/codex_bagel_repro_plan.md
ls -lah
find . -maxdepth 2 -type f | sort | head -200
ls -lah models || true
ls -lah models/BAGEL-7B-MoT || true
find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
du -sh models/BAGEL-7B-MoT || true
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader || true
find models/BAGEL-7B-MoT -maxdepth 3 -type f -name "*.safetensors" -printf "%p\t%s bytes\n" | sort
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do test -f "$f" && echo "OK $f" || echo "MISSING $f"; done
du -ah models/BAGEL-7B-MoT | sort -h | tail -40
```

## 关键输出

仓库路径：

```text
/root/autodl-tmp/BAGEL
```

仓库顶层关键文件和目录存在：

```text
AGENTS.md
README.md
app.py
inferencer.py
modeling/
data/
eval/
scripts/
scripts_local/
test_images/
models/
docs/codex_bagel_repro_plan.md
```

权重目录存在：

```text
models/BAGEL-7B-MoT
```

权重目录顶层文件：

```text
config.json
generation_config.json
llm_config.json
merges.txt
model.safetensors.index.json
preprocessor_config.json
tokenizer.json
tokenizer_config.json
vit_config.json
vocab.json
```

重要文件检查结果：

```text
OK models/BAGEL-7B-MoT/llm_config.json
OK models/BAGEL-7B-MoT/vit_config.json
MISSING models/BAGEL-7B-MoT/ae.safetensors
MISSING models/BAGEL-7B-MoT/ema.safetensors
```

`.safetensors` 搜索结果为空，说明当前 `models/BAGEL-7B-MoT` 三层深度内没有完整的 `.safetensors` 文件。

磁盘占用：

```text
11G models/BAGEL-7B-MoT
```

进一步检查显示 `11G` 主要来自未完成下载文件：

```text
11G models/BAGEL-7B-MoT/.cache/huggingface/download/9tCFHIjRQQGlCixyu3Q7Qzkl6Xo=.0b41c43835fd737b8c948e604870da522c091dcf151f3e8d55f84781765ee1a3.incomplete
```

GPU 显存快照：

```text
NVIDIA GeForce RTX 4090, 1 MiB, 24564 MiB
NVIDIA GeForce RTX 4090, 1 MiB, 24564 MiB
```

Task 1 检查运行时间：

```text
Runtime seconds: 1
```

## 报错 / 警告

首次尝试使用默认 sandbox 执行只读命令时失败，原始报错：

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces.
```

中文解释：当前机器内核或容器配置不允许默认 sandbox 创建非特权 namespace，因此后续只读检查命令改为在批准的外部执行环境中运行。该问题属于执行环境限制，不是 BAGEL 代码错误。

权重完整性警告：

- `models/BAGEL-7B-MoT/llm_config.json` 存在。
- `models/BAGEL-7B-MoT/vit_config.json` 存在。
- `models/BAGEL-7B-MoT/ae.safetensors` 缺失。
- `models/BAGEL-7B-MoT/ema.safetensors` 缺失。
- 当前目录中没有发现完整 `.safetensors` 权重文件。
- `11G` 占用来自 Hugging Face `.incomplete` 文件，说明权重下载很可能未完成。

## 修复尝试

本任务只做仓库和权重检查，没有修改 BAGEL 模型代码，也没有删除或覆盖任何权重、缓存、日志或输出文件。

执行环境方面的处理：

- 记录了默认 sandbox 的 `bwrap` 报错。
- 使用外部执行权限继续完成只读检查和日志记录。

权重缺失方面：

- 未自动重新下载权重。
- 未删除 `.incomplete` 文件。
- 未修改 checkpoint 加载逻辑。

## 结果

Task 1 已完成，但权重检查结论为：当前 `models/BAGEL-7B-MoT` 不完整。

仓库源码结构基本完整，`app.py`、`inferencer.py`、`modeling/`、`data/` 等关键文件存在。模型目录也存在，但缺少 Task 1 计划指定的 `ae.safetensors` 和 `ema.safetensors`，并且未发现完整 `.safetensors` 权重文件。当前 `11G` 磁盘占用主要来自 Hugging Face 下载缓存中的 `.incomplete` 文件，不能视为完整权重。

因此，在不补齐权重前，Task 2 启动官方 UI 很可能会在模型加载阶段失败。

## 可用于 PPT 的记录

- BAGEL 仓库源码结构已确认存在，核心入口包括 `app.py` 和 `inferencer.py`。
- `models/BAGEL-7B-MoT` 目录存在，但权重文件不完整。
- 配置文件 `llm_config.json`、`vit_config.json` 存在。
- 关键权重 `ae.safetensors`、`ema.safetensors` 缺失。
- 没有发现完整 `.safetensors` 文件。
- `11G` 权重目录占用主要来自 Hugging Face `.incomplete` 下载缓存，说明下载疑似中断。
- 机器有 2 张 RTX 4090，检查时每张 GPU 仅使用约 `1 MiB / 24564 MiB`。
- Task 2 之前需要先补齐或重新下载 BAGEL 权重。

