# Task 12：num_timesteps Ablation

## 目标

准备一个可手动运行的 `num_timesteps` 文生图消融实验脚本，观察采样步数对速度和图像质量的影响。

根据更新后的 `AGENTS.md`，GPU 推理任务不由 Codex 直接运行；本阶段只准备脚本、路径、日志占位和记录模板。

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

## 执行命令

已执行的轻量检查和脚本准备命令记录在：

```text
repro_records/task12_20260601_211039/commands.sh
```

手动运行 task12 生成任务时使用：

```bash
bash repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
```

脚本会优先使用：

```bash
/root/miniconda3/bin/conda run -n bagel python
```

如果需要覆盖解释器，可以指定：

```bash
PYTHON_BIN=/root/miniconda3/envs/bagel/bin/python bash repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
```

## 关键输出

脚本将生成以下图片：

```text
repro_records/task12_20260601_211039/outputs/steps_10.png
repro_records/task12_20260601_211039/outputs/steps_30.png
repro_records/task12_20260601_211039/outputs/steps_50.png
```

脚本将写入详细日志：

```text
repro_records/task12_20260601_211039/logs/ablation_timesteps.log
```

当前阶段尚未生成图片；需要用户手动运行脚本后，再根据输出图片和日志补充最终分析。

## 报错 / 警告

当前未运行 GPU 推理，因此没有模型推理错误。

## 修复尝试

未修改 BAGEL 核心模型逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

本任务仅新增 task12 记录文件和手动运行脚本：

```text
repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
repro_records/task12_20260601_211039/09_ablation_timesteps.md
repro_records/task12_20260601_211039/commands.sh
repro_records/task12_20260601_211039/logs/ablation_timesteps.log
```

## 结果

Task 12 脚本准备完成。按照更新后的 GPU 执行策略，Codex 未启动模型推理。

用户手动运行脚本后，应提供：

```text
repro_records/task12_20260601_211039/logs/ablation_timesteps.log
repro_records/task12_20260601_211039/outputs/steps_10.png
repro_records/task12_20260601_211039/outputs/steps_30.png
repro_records/task12_20260601_211039/outputs/steps_50.png
```

之后再补充 `num_timesteps` 对生成速度、细节、稳定性和质量的影响分析。

## 可用于 PPT 的记录

- Task12 采用脚本化方式准备 `num_timesteps` 消融。
- 固定 prompt、seed、文本 CFG、低显存模式和 thinking 关闭状态，只改变采样步数。
- 预期观察重点：步数增加是否带来更细致结构、更稳定光照、更少噪声，以及额外耗时是否值得。
