# Task 13：BAGEL 工程复现 PPT 汇总

## 目标

将已完成的 BAGEL 复现任务整理为可直接转成中文 PPT 的工程总结，覆盖：

- 实际执行内容
- 环境与仓库状态
- 权重完整性
- 模型加载流程
- 推理数据流
- 已测试任务
- 消融实验结果
- 问题与修复
- 工程洞察
- 局限性
- 后续改进

本任务只做报告汇总，没有运行新的模型推理或 GPU workload。

## 证据来源

- Task 0：`repro_records/20260531T080101Z/00_env_check.md`
- Task 1：`repro_records/20260531_210418/01_repo_and_weights_check.md`
- Task 2：`repro_records/20260601_141533/02_ui_launch.md`
- Task 3：`repro_records/task03_20260601_145116/summary_app_py.md`
- Task 4：`repro_records/task04_20260601_152117/summary_inferencer_py.md`
- Task 5：`repro_records/task05_20260601_152705/minimal_cli.md`
- Task 6：`repro_records/task06_20260601_154840/03_task_t2i.md`
- Task 7：`repro_records/task07_20260601_083153/04_task_understanding.md`
- Task 8：`repro_records/task08_20260601_085406/05_task_editing.md`
- Task 9：`repro_records/task09/06_ablation_thinking.md`
- Task 10：`repro_records/task10_20260601_102643/07_ablation_cfg_text_scale.md`
- Task 11：`repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md`
- Task 12：`repro_records/task12_20260601_211039/09_ablation_timesteps.md`

## 一页结论

- BAGEL 官方 WebUI 已在 `mode=2` 低显存量化模式下启动成功。
- 已新增并验证最小 CLI：`scripts/run_bagel_minimal.py`，可绕过 Gradio 直接执行文生图、图像理解和图像编辑。
- 三类核心任务均已跑通：Text-to-Image、Image Understanding、Image Editing。
- 已完成四类消融：thinking mode、`cfg_text_scale`、`cfg_img_scale`、`num_timesteps`。
- 主要工程问题集中在环境选择、日志捕获、系统工具缺失和 sandbox 限制，不是 BAGEL 核心模型逻辑错误。
- `mode=2` 下多次推理的 PyTorch 峰值显存大致稳定在 GPU0 `11.27GiB`、GPU1 `12.36GiB`。
- 单样本结论：`num_timesteps=30` 在 task12 prompt 下比 10 步质量更稳，比 50 步更节省时间，是较均衡的折中点。

## 实际执行

- Task 0：完成环境检查，确认 `bagel` conda 环境、PyTorch CUDA、双 RTX 4090、关键依赖和磁盘状态。
- Task 1：完成仓库和权重文件检查，确认 `llm_config.json`、`vit_config.json`、`ae.safetensors`、`ema.safetensors` 均存在。
- Task 2：成功启动官方 Gradio UI，使用 `mode=2`，端口 `7860` 返回 `HTTP/1.1 200 OK`。
- Task 5：创建并 smoke test 最小 CLI，图像理解任务成功输出文本。
- Task 6：文生图 baseline 成功生成 `t2i_baseline.png`。
- Task 7：图像理解 baseline 成功生成 `understanding_baseline.txt`。
- Task 8：图像编辑 baseline 成功生成 `edit_baseline.png`。
- Task 9：thinking ablation 完成 `think=False` 与 `think=True` 两组图像，并生成 thinking 文本。
- Task 10：`cfg_text_scale=1.0 / 4.0 / 8.0` 三组文生图消融完成。
- Task 11：`cfg_img_scale=1.0 / 2.0 / 4.0` 三组图像编辑消融完成。
- Task 12：`num_timesteps=10 / 30 / 50` 三组文生图消融完成。

## 代码阅读

- Task 3：静态分析 `app.py`，确认官方 UI 的模型加载、tokenizer、VAE/ViT transform、三个推理入口和 Gradio 事件绑定。
- Task 4：静态分析 `inferencer.py`，确认 interleaved inference 的上下文组织、文本/图像更新、thinking mode 和图像/文本生成分支。

## 状态分类

- 实际执行：Task 0、Task 1、Task 2、Task 5、Task 6、Task 7、Task 8、Task 9、Task 10、Task 11、Task 12。
- 仅从代码检查：Task 3 的 `app.py` 分析，Task 4 的 `inferencer.py` 分析。
- 失败或警告：默认 Python 缺少依赖、部分系统工具缺失、safetensors metadata 警告、CPU offload 提示、一次 thinking 日志 wrapper 语法错误、Codex sandbox 限制。
- 已修复或处理：切换到 `bagel` conda 环境、改用替代工具检查 UI/进程、创建最小 CLI、修正 thinking 重跑命令、补完 task12 最终报告。
- 未验证：`mode=1`、`mode=3`、多 seed 稳定性、多 prompt 统计结论、Task 9/10/11 的系统人工视觉评分、与其他模型或官方样例的定量对比。

## 环境摘要

- 运行路径：`/root/autodl-tmp/BAGEL`
- Git 提交：`a2fa77dd8caeefc41e6607ae0ec17408d3f4ee9f`
- Python：`3.10.20`
- Python 环境：`/root/miniconda3/envs/bagel/bin/python`
- PyTorch：`2.5.1+cu124`
- CUDA 可用：`torch.cuda.is_available() = True`
- GPU：2x `NVIDIA GeForce RTX 4090`，每张约 24GB VRAM
- 关键依赖：`accelerate`、`bitsandbytes`、`flash-attn`、`gradio`、`transformers`、`safetensors`
- 环境风险：根文件系统剩余约 `4.0G`，`/autodl-pub` 使用率约 `96%`

## 仓库与权重

- 仓库关键入口：
  - `app.py`：官方 Gradio UI 和模型加载入口。
  - `inferencer.py`：interleaved inference 封装。
  - `scripts/run_bagel_minimal.py`：本轮新增的最小 CLI。
  - `docs/codex_bagel_repro_plan.md`：复现任务计划。
  - `repro_records/`：所有任务记录、日志和输出。
  - `test_images/`：图像理解和编辑 baseline 使用的本地测试图。
- 默认模型目录：`models/BAGEL-7B-MoT`
- 关键配置文件存在：
  - `models/BAGEL-7B-MoT/llm_config.json`
  - `models/BAGEL-7B-MoT/vit_config.json`
- 关键权重文件存在：
  - `models/BAGEL-7B-MoT/ae.safetensors`，约 `320M`
  - `models/BAGEL-7B-MoT/ema.safetensors`，约 `28G`
- Task 1 只证明文件系统层面存在，不单独证明权重内容完全正确。
- 后续模型加载和推理任务成功，进一步说明这些权重至少可被当前流程加载使用。

## 模型加载流程

- `app.py` 读取 `llm_config.json` 构造 `Qwen2Config`，并设置 MoT decoder layer 相关参数。
- `app.py` 读取 `vit_config.json` 构造 `SiglipVisionConfig`，并调整 ViT 层数和 RoPE 设置。
- 调用 `load_ae()` 加载 VAE 权重 `ae.safetensors`。
- 使用 `BagelConfig` 组合 LLM、ViT、VAE 配置。
- 在 `init_empty_weights()` 中创建空权重模型：`Qwen2ForCausalLM`、`SiglipVisionModel`、`Bagel`。
- 使用 `accelerate.infer_auto_device_map()` 生成 device map，并设置多 GPU/CPU offload 策略。
- `mode=1`：bf16 checkpoint dispatch。
- `mode=2`：NF4 4bit 量化加载，本次主要使用该模式。
- `mode=3`：INT8 量化加载，本轮未实际验证。
- tokenizer 使用 `Qwen2Tokenizer.from_pretrained(model_path)`，再调用 `add_special_tokens()`。
- `vae_transform = ImageTransform(1024, 512, 16)`。
- `vit_transform = ImageTransform(980, 224, 14)`。
- 最终创建 `InterleaveInferencer` 作为统一推理封装。

## 推理数据流

- `InterleaveInferencer.init_gen_context()` 创建 KV cache、RoPE 位置和序列长度上下文。
- `update_context_text()` 将文本 prompt 编码并写入 KV cache。
- `update_context_image()` 将图像写入上下文，支持 VAE 生成条件路径和 ViT 理解路径。
- `understanding_output=True`：图像只走 ViT 路径，最终调用 `gen_text()` 输出文本。
- `understanding_output=False`：图像可走 VAE + ViT 条件路径，最终调用 `gen_image()` 输出图像。
- `think=True`：先写入 thinking system prompt；生成/编辑任务会先生成 planning 文本，再把 planning 文本写回上下文，然后生成图像。
- `cfg_text_scale` 控制文本条件 guidance 强度。
- `cfg_img_scale` 控制图像编辑时输入图像条件强度。
- `num_timesteps` 控制图像生成采样步数，直接影响耗时和细节稳定性。

## Baseline 结果

| 任务 | 输出 | model_load_seconds | inference_seconds | total_seconds | 状态 |
| --- | --- | ---: | ---: | ---: | --- |
| Task 5 smoke understanding | `smoke_understanding.txt` | 24.65 | 46.10 | 70.82 | 成功 |
| Task 6 text-to-image | `t2i_baseline.png` | 24.71 | 136.75 | 162.26 | 成功 |
| Task 7 image understanding | `understanding_baseline.txt` | 24.01 | 148.33 | 172.41 | 成功 |
| Task 8 image editing | `edit_baseline.png` | 25.81 | 133.53 | 159.98 | 成功 |

- Task 6 输出：`1024 x 1024` RGB PNG。
- Task 7 输出文本能正确描述 meme 图片结构和含义。
- Task 8 输出：`800 x 1024` RGB PNG。
- 多次 baseline 说明最小 CLI 覆盖了三类核心任务，不依赖 Gradio UI。

## 消融结果

### Thinking Mode

| 设置 | 输出 | inference_seconds | total_seconds | 备注 |
| --- | --- | ---: | ---: | --- |
| `think=False` | `think_false.png` | 136.26 | 161.71 | 成功 |
| `think=True` | `think_true.png` + thinking text | 263.60 | 289.84 | 成功 |

- `think=True` 比 `think=False` 多约 `128.13s`，总耗时约为 `1.79x`。
- thinking 文本会把原 prompt 扩展成更详细的场景规划。
- 当前记录能证明 thinking 增加了上下文和耗时；视觉质量收益尚未系统量化。

### CFG Text Scale

| cfg_text_scale | total_seconds | inference_seconds | 输出 |
| ---: | ---: | ---: | --- |
| 1.0 | 122.11 | 97.38 | `cfg_text_1.png` |
| 4.0 | 159.50 | 134.05 | `cfg_text_4.png` |
| 8.0 | 158.85 | 134.17 | `cfg_text_8.png` |

- 三组均生成 `1024 x 1024` 图片。
- `cfg_text_scale=1.0` 在本次单样本中推理时间较短。
- `4.0` 与 `8.0` 的耗时接近。
- 原报告只完成文件、统计和日志验证，未写入人工视觉优劣结论。

### CFG Image Scale

| cfg_img_scale | total_seconds | inference_seconds | 输出 |
| ---: | ---: | ---: | --- |
| 1.0 | 122.10 | 97.44 | `cfg_img_1.png` |
| 2.0 | 154.67 | 130.21 | `cfg_img_2.png` |
| 4.0 | 154.82 | 130.30 | `cfg_img_4.png` |

- 三组均生成 `800 x 1024` 图片。
- `cfg_img_scale=1.0` 在本次单样本中推理时间较短。
- `2.0` 与 `4.0` 的耗时和显存表现接近。
- 像素差异不等价于“主体保持”或“编辑强度”，仍需人工视觉评估。

### num_timesteps

| num_timesteps | total_seconds | inference_seconds | wall_seconds | 输出 |
| ---: | ---: | ---: | ---: | --- |
| 10 | 76.73 | 51.81 | 84 | `steps_10.png` |
| 30 | 156.29 | 131.50 | 163 | `steps_30.png` |
| 50 | 242.63 | 217.11 | 251 | `steps_50.png` |

- 三组均生成赛博朋克雨夜街道图片。
- 10 步：构图成立，霓虹和反光明显，但局部纹理粗糙、细节更不稳定。
- 30 步：建筑边缘、路面反光、电线和招牌布局更稳定，是本次更均衡的速度/质量折中。
- 50 步：继续增加远处车辆、线缆和局部细节，但相对 30 步的边际收益小于耗时增长。

## 问题与修复

- 问题：默认 Python 缺少 `gradio`，导致官方 UI 首次启动失败。
- 修复：改用 `/root/miniconda3/bin/conda run -n bagel python ...`。

- 问题：默认 Python 缺少 `accelerate`，导致 CLI help 首次失败。
- 修复：同样切换到 `bagel` conda 环境。

- 问题：`ss`、`lsof`、`/usr/bin/time` 等系统工具缺失。
- 修复：用 `curl`、`ps`、`netstat`、CLI 内置 runtime 记录替代。

- 问题：`conda run` 输出缓冲，UI 日志没有及时出现 Gradio URL。
- 修复：用浏览器确认和 `curl -I http://127.0.0.1:7860` 验证可访问性。

- 问题：`ema.safetensors` 缺少 metadata。
- 处理：记录为警告；加载器回退默认 `pt` metadata，未阻断模型加载和推理。

- 问题：`mode=2` 下出现 CPU offload / meta device 提示。
- 处理：记录为低显存量化加载的可解释现象；未导致推理失败。

- 问题：某次 thinking 日志 wrapper 有换行转义错误，触发 `SyntaxError`。
- 修复：改用单行 wrapper 后重新运行成功。

- 问题：Codex sandbox 多次出现 `bwrap` / Windows sandbox 初始化限制。
- 处理：只对必要的只读检查和记录文件操作使用批准后的非沙箱执行；未绕过 GPU 执行规则。

- 问题：Task12 旧报告仍写着“图片尚未生成”。
- 修复：基于用户已运行的日志和图片，更新为最终实验记录。

## 工程洞察

- `mode=2` NF4 量化是当前 2x RTX 4090 环境下稳定复现实验的主路径。
- CLI 化比 Gradio 更适合复现实验：参数固定、输出路径可控、日志可复查、适合 ablation。
- 每次 CLI 单独加载模型约 24 到 26 秒，批量消融如果能复用模型实例，可显著减少重复加载开销。
- 多个实验的 PyTorch 峰值显存接近，说明显存瓶颈主要来自模型加载和统一推理路径，而不是单个 prompt 差异。
- `num_timesteps` 对耗时影响最直接，50 步明显更慢；在单样本中 30 步已有较好稳定性。
- thinking mode 会显著增加文本生成阶段耗时，是否值得需要用更多 prompt 和人工评分验证。
- CFG 相关消融需要结合视觉评价，单纯文件大小、RGB 统计或像素差异不能直接代表质量。

## 局限性

- 所有 baseline 和 ablation 基本都是单 prompt、单 seed，不能代表统计稳定结论。
- `mode=1` 和 `mode=3` 未系统验证。
- 没有做多 seed、多 prompt、多图像输入的鲁棒性测试。
- Task 9/10/11 的视觉质量仍缺少系统人工评分表。
- 没有和其他模型或官方样例结果做定量对比。
- 没有做吞吐量、显存峰值分阶段剖析或批量推理优化。
- 没有修改或验证 BAGEL 核心模型逻辑，当前结论主要围绕复现工程和推理调用。

## 后续改进

- 把 CLI 改造成可一次加载模型、连续运行多组参数的 batch runner，减少重复模型加载时间。
- 增加统一实验配置文件，例如 YAML/JSON，避免手写长命令。
- 为每个生成任务增加人工评分表：prompt 遵循度、细节、构图、伪影、主体保持、背景替换程度。
- 对关键消融补充多 seed 结果，区分偶然样本和稳定规律。
- 验证 `mode=1` / `mode=3` 的显存、速度和质量差异。
- 增加自动图片元数据记录：尺寸、文件大小、hash、RGB 统计、可选 CLIP 相似度。
- 对 UI 和 CLI 的加载流程抽成共享 helper，减少 `app.py` 与 `scripts/run_bagel_minimal.py` 的重复逻辑。

## 最终状态

- Task13 已完成。
- 输出文件：`repro_records/task13_20260602_172339/summary_for_ppt.md`
- 命令记录：`repro_records/task13_20260602_172339/commands.sh`
- 构建日志：`repro_records/task13_20260602_172339/logs/summary_build.log`
- 本任务未执行 GPU 推理，未修改 BAGEL 核心模型代码。
