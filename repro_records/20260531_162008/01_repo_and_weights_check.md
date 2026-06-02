# Task 1：Repository and Weight Check

## 目标

检查 BAGEL 仓库结构，以及 `models/BAGEL-7B-MoT` 模型权重是否完整。

本任务只做只读检查：未启动 UI，未加载模型，未运行推理，未修改核心模型逻辑。

## 执行命令

完整命令记录见：

- `/root/autodl-tmp/BAGEL/repro_records/20260531_162008/commands.sh`

原始日志见：

- `/root/autodl-tmp/BAGEL/repro_records/20260531_162008/logs/weights_check.log`

本任务执行的主要检查命令包括：

```bash
ls -lah
find . -maxdepth 2 -type f | sort | head -200
ls -lah models || true
ls -lah models/BAGEL-7B-MoT || true
find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
du -sh models/BAGEL-7B-MoT || true
```

为判断权重完整性，额外执行了只读补充检查：

```bash
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do if [ -f "$f" ]; then ls -lh "$f"; else echo "MISSING $f"; fi; done
find models/BAGEL-7B-MoT -type f -name '*.safetensors*' -printf '%p %s bytes\n' | sort | head -300 || true
find models/BAGEL-7B-MoT/.cache -maxdepth 5 -type f -printf '%p %s bytes\n' | sort | head -300 || true
du -ah models/BAGEL-7B-MoT | sort -h | tail -50 || true
```

并解析 `model.safetensors.index.json`，确认 index 引用的 shard 是否存在。

## 关键输出

仓库顶层结构存在，关键源码文件包括：

- `/root/autodl-tmp/BAGEL/app.py`
- `/root/autodl-tmp/BAGEL/inferencer.py`
- `/root/autodl-tmp/BAGEL/modeling/`
- `/root/autodl-tmp/BAGEL/data/`
- `/root/autodl-tmp/BAGEL/scripts/`
- `/root/autodl-tmp/BAGEL/test_images/`
- `/root/autodl-tmp/BAGEL/docs/codex_bagel_repro_plan.md`

模型目录存在：

- `/root/autodl-tmp/BAGEL/models/BAGEL-7B-MoT`

模型目录顶层可见文件包括：

- `config.json`
- `generation_config.json`
- `llm_config.json`
- `vit_config.json`
- `model.safetensors.index.json`
- `tokenizer.json`
- `tokenizer_config.json`
- `merges.txt`
- `vocab.json`
- `preprocessor_config.json`

目录占用：

```text
11G models/BAGEL-7B-MoT
```

关键配置文件检查结果：

```text
models/BAGEL-7B-MoT/llm_config.json 存在，大小 663 bytes
models/BAGEL-7B-MoT/vit_config.json 存在，大小 205 bytes
```

关键权重文件检查结果：

```text
MISSING models/BAGEL-7B-MoT/ae.safetensors
MISSING models/BAGEL-7B-MoT/ema.safetensors
```

解析 `model.safetensors.index.json` 的结果：

```text
index_exists: True
shard_count_in_index: 2
missing_shard_count: 2
MISSING ae.safetensors
MISSING ema.safetensors
```

隐藏缓存中发现未完成下载文件：

```text
models/BAGEL-7B-MoT/.cache/huggingface/download/9tCFHIjRQQGlCixyu3Q7Qzkl6Xo=.0b41c43835fd737b8c948e604870da522c091dcf151f3e8d55f84781765ee1a3.incomplete 11723079680 bytes
models/BAGEL-7B-MoT/.cache/huggingface/download/I1ZtT7xUl9700oQxiUVoRlAzmhA=.afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38.incomplete 0 bytes
```

## 报错 / 警告

没有出现 shell 命令执行失败导致任务中断的报错。

主要问题是权重不完整：

- `ae.safetensors` 缺失。
- `ema.safetensors` 缺失。
- `model.safetensors.index.json` 引用的 2 个 shard 均不存在。
- `models/BAGEL-7B-MoT/.cache/huggingface/download/` 下存在 `.incomplete` 文件，说明下载很可能未完成或中断。

## 修复尝试

本任务未进行修复。

原因：

- AGENTS.md 要求不要删除用户文件、checkpoint、日志或生成结果。
- 当前问题属于模型权重下载不完整，需要用户确认是否继续下载或重新获取权重。
- 未删除 `.incomplete` 文件，未覆盖任何已有文件。

## 结果

Task 1 已完成，但权重检查未通过。

结论：

- 仓库结构基本完整。
- `models/BAGEL-7B-MoT` 目录存在。
- tokenizer 和配置文件存在。
- 核心权重文件 `ae.safetensors` 与 `ema.safetensors` 缺失。
- 当前状态不适合继续启动 UI 或运行推理，因为模型加载预计会因缺失权重失败。

GPU 显存：

- 本任务没有运行模型加载或 GPU 推理，因此未产生 GPU 显存占用数据。

运行时间：

- 本任务为文件系统检查，命令均快速完成；未进行长时间计算任务。

## 可用于 PPT 的记录

- BAGEL 仓库源码结构存在，包含 `app.py`、`inferencer.py`、`modeling/`、`data/` 等关键模块。
- 本地模型目录 `models/BAGEL-7B-MoT` 存在，但权重不完整。
- `llm_config.json` 和 `vit_config.json` 存在，说明模型配置文件已下载。
- `model.safetensors.index.json` 指向 `ae.safetensors` 和 `ema.safetensors` 两个权重文件。
- 实际检查发现 `ae.safetensors` 和 `ema.safetensors` 均缺失。
- 隐藏 Hugging Face 缓存目录中存在约 `11G` 的 `.incomplete` 文件，推测模型下载中断。
- 在补齐权重前，不建议继续执行 UI 启动或推理任务。
