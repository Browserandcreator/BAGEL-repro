# Task 4 PPT Summary

- 本任务分析对象：`inferencer.py`，共 313 行。
- 核心类：`InterleaveInferencer`，负责把文本、图像和生成参数组织成 BAGEL 的 interleaved inference 上下文。
- 核心状态：`gen_context`，包含 `kv_lens`、`ropes`、`past_key_values`。
- 文本路径：`update_context_text()` 调用 `prepare_prompts()` 和 `forward_cache_update_text()`，把 prompt 写入 KV cache。
- 图像路径：`update_context_image()` 可走 VAE 路径、ViT 路径或二者同时使用。
- 图像理解：`understanding_output=True` 时，图像不走 VAE 条件路径，只走 ViT，最终调用 `gen_text()` 输出文本。
- 图像生成/编辑：`understanding_output=False` 时，图像可走 VAE + ViT 条件路径，最终调用 `gen_image()` 输出图像。
- Thinking mode：先写入 system prompt；生成/编辑任务会先生成 planning 文本，再把 planning 文本写回上下文，然后生成图像。
- 关键参数：`cfg_text_scale` 控制文本 guidance，`cfg_img_scale` 控制图像 guidance，`num_timesteps` 控制采样步数。
- 本任务只做代码检查，没有启动模型推理，没有验证实际生成质量。
