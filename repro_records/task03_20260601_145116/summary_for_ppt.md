# PPT Summary

## Task 3：`app.py` 代码分析

- `app.py` 是官方 Gradio WebUI 主入口，负责参数解析、模型加载、推理函数和 UI 事件绑定。
- 默认模型路径是 `models/BAGEL-7B-MoT`。
- 模型加载包括 `llm_config.json`、`vit_config.json`、`ae.safetensors` 和 `ema.safetensors`。
- `mode 1` 使用 bf16 checkpoint dispatch，`mode 2` 使用 NF4 4bit 量化，`mode 3` 使用 INT8 量化。
- tokenizer 使用 `Qwen2Tokenizer.from_pretrained(model_path)`，随后调用 `add_special_tokens()`。
- VAE transform：`ImageTransform(1024, 512, 16)`。
- ViT transform：`ImageTransform(980, 224, 14)`。
- `InterleaveInferencer` 接收 model、VAE、tokenizer、两套 transform 和特殊 token，是 UI 推理的统一后端。
- 文生图入口：`text_to_image()`，输入文本 prompt，输出图像，可选 thinking 文本。
- 图像编辑入口：`edit_image()`，输入 image + prompt，输出编辑后图像，可选 thinking 文本。
- 图像理解入口：`image_understanding()`，输入 image + prompt，设置 `understanding_output=True`，输出文本。
- `think=True` 会加入 thinking system prompt，并在生成/理解前产生思考或规划文本。
- `cfg_text_scale` 控制文本提示词约束强度。
- `cfg_img_scale` 只在图像编辑中暴露，控制输入图像内容保留强度。
- `num_timesteps` 控制图像生成/编辑的去噪采样步数，默认 50。
- 本任务只做代码阅读，没有运行推理，没有修改代码。
