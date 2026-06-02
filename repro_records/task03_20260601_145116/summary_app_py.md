# Task 3: Analyze app.py

## 目标

阅读 `app.py`，总结官方 Gradio UI 的推理入口和模型加载流程，重点覆盖：

- 模型初始化
- tokenizer 加载
- VAE transform
- ViT transform
- `InterleaveInferencer` 初始化
- `text_to_image()`
- `image_understanding()`
- `edit_image()`
- `cfg_text_scale`、`cfg_img_scale`、`num_timesteps`、`think` 等参数

本任务只做静态代码阅读，没有启动新推理，没有生成图片，没有修改代码。

## 执行命令

记录目录：

```bash
repro_records/task03_20260601_145116/
```

主要命令：

```bash
sed -n '1,260p' AGENTS.md
sed -n '1,220p' docs/codex_bagel_repro_plan.md
ls -la repro_records
sed -n '1,260p' app.py
sed -n '260,620p' app.py
grep -n "def \|class \|InterleaveInferencer\|cfg_text_scale\|cfg_img_scale\|num_timesteps\|think\|tokenizer\|transforms" app.py
wc -l app.py
grep -n "class InterleaveInferencer\|def __call__\|def interleave_inference\|understanding_output" inferencer.py
sed -n '1,220p' inferencer.py
sed -n '220,420p' inferencer.py
```

完整命令记录：

```bash
repro_records/task03_20260601_145116/commands.sh
```

代码分析日志：

```bash
repro_records/task03_20260601_145116/logs/app_py_analysis.log
```

## 关键输出

### 1. `app.py` 的整体职责

`app.py` 是官方 Gradio WebUI 的主入口，承担三类职责：

1. 解析启动参数：`--server_name`、`--server_port`、`--share`、`--model_path`、`--mode`、`--zh`。
2. 加载 BAGEL 模型、tokenizer、VAE、ViT、图像 transform，并创建 `InterleaveInferencer`。
3. 定义三个 Gradio 推理入口：文生图、图像编辑、图像理解。

代码位置：

- 参数解析：`app.py` 约第 20-26 行
- 模型初始化：`app.py` 约第 29-143 行
- 三个推理函数：`app.py` 约第 161-256 行
- Gradio UI 和事件绑定：`app.py` 约第 268-612 行

### 2. 模型初始化流程

`app.py` 默认模型路径为：

```text
models/BAGEL-7B-MoT
```

初始化流程：

1. 读取 `llm_config.json`，构造 `Qwen2Config`。
2. 修改 LLM 配置：
   - `qk_norm = True`
   - `tie_word_embeddings = False`
   - `layer_module = "Qwen2MoTDecoderLayer"`
3. 读取 `vit_config.json`，构造 `SiglipVisionConfig`。
4. 修改 ViT 配置：
   - `rope = False`
   - `num_hidden_layers -= 1`
5. 调用 `load_ae()` 加载 VAE 权重 `ae.safetensors`。
6. 用 `BagelConfig` 组合 LLM、ViT、VAE 配置。
7. 在 `init_empty_weights()` 中先创建空权重模型：
   - `Qwen2ForCausalLM`
   - `SiglipVisionModel`
   - `Bagel`
8. 调用 `convert_conv2d_to_linear()` 处理 ViT embedding。
9. 根据 `--mode` 选择加载 `ema.safetensors` 的方式。

`--mode` 含义：

- `mode 1`：`load_checkpoint_and_dispatch()`，bfloat16，多 GPU/offload。
- `mode 2`：NF4 4bit 量化，调用 `load_and_quantize_model()`。
- `mode 3`：INT8 量化，调用 `load_and_quantize_model()`。

### 3. Device map 和多 GPU 准备

`app.py` 使用 `accelerate.infer_auto_device_map()` 自动生成 device map。

显存限制：

```python
max_memory={**{i: "20GiB" for i in range(torch.cuda.device_count())}, "cpu": "80GiB"}
```

并设置不拆分模块：

```python
no_split_module_classes=["Bagel", "Qwen2MoTDecoderLayer"]
```

部分模块被强制放在同一设备上，例如：

```text
language_model.model.embed_tokens
time_embedder
latent_pos_embed
vae2llm
llm2vae
connector
vit_pos_embed
```

推测目的：这些模块在生成路径中关系紧密，放在同一设备可以减少跨设备传输或避免 device mismatch。

### 4. Tokenizer 加载

tokenizer 加载逻辑：

```python
tokenizer = Qwen2Tokenizer.from_pretrained(model_path)
tokenizer, new_token_ids, _ = add_special_tokens(tokenizer)
```

`new_token_ids` 会传给 `InterleaveInferencer`，后续用于文本 prompt、图像 token、起止 token 等特殊 token 处理。

### 5. VAE transform 和 ViT transform

`app.py` 中有两套图像 transform：

```python
vae_transform = ImageTransform(1024, 512, 16)
vit_transform = ImageTransform(980, 224, 14)
```

从调用关系看：

- `vae_transform` 用于生成/编辑路径中的 VAE 图像编码或 latent 相关处理。
- `vit_transform` 用于图像理解或视觉条件输入的 ViT 处理。

在 `inferencer.py` 中，`update_context_image()` 会按 `vae` / `vit` 参数决定是否走 VAE 或 ViT 图像上下文更新。

### 6. `InterleaveInferencer` 初始化

`app.py` 初始化：

```python
inferencer = InterleaveInferencer(
    model=model,
    vae_model=vae_model,
    tokenizer=tokenizer,
    vae_transform=vae_transform,
    vit_transform=vit_transform,
    new_token_ids=new_token_ids,
)
```

也就是说，`app.py` 本身不直接实现底层生成循环，而是把模型、VAE、tokenizer、图像预处理和特殊 token 交给 `InterleaveInferencer`。

`InterleaveInferencer.__call__()` 接收可选 `image` 和 `text`，内部构造 interleaved input list，再返回：

```python
{'image': None, 'text': None}
```

其中生成图像会放在 `result["image"]`，生成文本或 thinking 文本会放在 `result["text"]`。

### 7. `text_to_image()` 路径

入口函数：

```python
text_to_image(prompt, show_thinking=False, cfg_text_scale=4.0, cfg_interval=0.4,
              timestep_shift=3.0, num_timesteps=50,
              cfg_renorm_min=0.0, cfg_renorm_type="global",
              max_think_token_n=1024, do_sample=False, text_temperature=0.3,
              seed=0, image_ratio="1:1")
```

流程：

1. 调用 `set_seed(seed)` 固定随机性。
2. 根据 `image_ratio` 选择输出尺寸：
   - `1:1` -> `(1024, 1024)`
   - `4:3` -> `(768, 1024)`
   - `3:4` -> `(1024, 768)`
   - `16:9` -> `(576, 1024)`
   - `9:16` -> `(1024, 576)`
3. 组装 `inference_hyper`。
4. 调用：

```python
result = inferencer(text=prompt, think=show_thinking, **inference_hyper)
```

5. 返回：

```python
return result["image"], result.get("text", None)
```

含义：

- 不开启 thinking 时，主要返回生成图像。
- 开启 thinking 时，`result["text"]` 可能包含生成前的 planning/thinking 文本。

### 8. `image_understanding()` 路径

入口函数：

```python
image_understanding(image, prompt, show_thinking=False,
                    do_sample=False, text_temperature=0.3, max_new_tokens=512)
```

流程：

1. 如果 image 为空，返回 `"Please upload an image."`。
2. 如果 image 是 `np.ndarray`，转为 PIL Image。
3. 调用 `pil_img2rgb()` 转 RGB。
4. 组装文本生成参数：
   - `do_sample`
   - `text_temperature`
   - `max_think_token_n=max_new_tokens`
5. 调用：

```python
result = inferencer(
    image=image,
    text=prompt,
    think=show_thinking,
    understanding_output=True,
    **inference_hyper
)
```

6. 返回：

```python
return result["text"]
```

关键区别：

- `understanding_output=True` 表示输出文本。
- 在 `inferencer.py` 中，该模式下输入图片更新上下文时 `vae=not understanding_output`，即图像理解路径不走 VAE 图像生成上下文，而主要走 ViT 视觉理解上下文。

### 9. `edit_image()` 路径

入口函数：

```python
edit_image(image, prompt, show_thinking=False, cfg_text_scale=4.0,
           cfg_img_scale=2.0, cfg_interval=0.0,
           timestep_shift=3.0, num_timesteps=50,
           cfg_renorm_min=0.0, cfg_renorm_type="text_channel",
           max_think_token_n=1024, do_sample=False,
           text_temperature=0.3, seed=0)
```

流程：

1. 调用 `set_seed(seed)`。
2. 检查输入图像是否为空。
3. 将 numpy 图像转 PIL，并转 RGB。
4. 组装 `inference_hyper`，比文生图多一个关键参数：

```python
cfg_img_scale=cfg_img_scale
```

5. 调用：

```python
result = inferencer(image=image, text=prompt, think=show_thinking, **inference_hyper)
```

6. 返回：

```python
return result["image"], result.get("text", "")
```

含义：

- 图像编辑输入同时包含 image 和 text。
- `inferencer` 会先把图像加入上下文，再加入文本 prompt，然后生成新图像。
- `cfg_img_scale` 控制保留输入图像细节的强度。

### 10. 关键参数解释

`think` / `show_thinking`：

- UI 中叫 `Thinking`。
- 传给 `inferencer(..., think=show_thinking)`。
- 在 `inferencer.py` 中，`think=True` 会先加入系统 thinking prompt。
- 对图像生成/编辑，thinking 文本会先生成，再追加进上下文，最后生成图像。
- 对图像理解，thinking prompt 使用 VLM 版本，最终输出文本。

`cfg_text_scale`：

- 文生图和图像编辑都有。
- 传给 `model.generate_image()`。
- 控制生成图像对文本 prompt 的遵循强度。
- UI 默认值为 `4.0`。

`cfg_img_scale`：

- 只在图像编辑 UI 中暴露。
- 默认值为 `2.0`。
- 传给 `model.generate_image()`。
- 用于控制编辑时保留输入图像信息的强度。

`num_timesteps`：

- 文生图和图像编辑都有。
- UI 范围为 `10-100`，默认 `50`。
- 传给 `model.generate_image()` 的 `num_timesteps`。
- 表示扩散/去噪采样步数，步数越高通常耗时越长。

`cfg_interval`：

- UI 中只控制起点，代码固定终点为 `1.0`：

```python
cfg_interval=[cfg_interval, 1.0]
```

`timestep_shift`：

- 文生图默认范围 `1.0-5.0`，编辑默认范围 `1.0-10.0`。
- 传给 `model.generate_image()`。
- UI 提示为较大值偏布局，较小值偏细节。

`cfg_renorm_type` / `cfg_renorm_min`：

- 用于 CFG renorm。
- 文生图默认 `cfg_renorm_type="global"`。
- 图像编辑默认 `cfg_renorm_type="text_channel"`。

### 11. Gradio UI 事件绑定

`app.py` 定义三个 Tab：

1. `Text to Image`
2. `Image Edit`
3. `Image Understanding`

事件绑定：

- 文生图：`gen_btn.click` 或 prompt submit -> `process_text_to_image()` -> `text_to_image()`
- 图像编辑：`edit_btn.click` 或 prompt submit -> `process_edit_image()` -> `edit_image()`
- 图像理解：`img_understand_btn.click` 或 prompt submit -> `process_understanding()` -> `image_understanding()`

`--zh` 会调用 `apply_localization(demo)`，将部分英文 UI label/info 替换成中文。

## 报错 / 警告

本任务为代码阅读，没有运行新的推理任务，因此没有新增运行时报错。

静态阅读中发现的工程注意点：

1. `app.py` 导入 `NaiveCache`，但该文件内未直接使用；实际 cache 使用在 `inferencer.py`。
2. `model_path = args.model_path` 在代码中出现两次，属于轻微重复，不影响运行。
3. `genrated` 拼写出现在 UI info 文案中，应为 `generated`，不影响推理。
4. `image_understanding()` 在 image 为空时返回字符串；Gradio 输出是文本框，因此可接受。
5. `edit_image()` 在 image 为空时返回 `("Please upload an image.", "")`，但正常输出期望为图像和文本；如果用户未上传图像，图像输出组件可能收到字符串。该路径未在本任务中实际测试。

## 修复尝试

无。

本任务没有修改代码，没有修改模型结构、forward 逻辑、tokenizer、VAE、ViT 或 checkpoint 加载语义。

## 结果

Task 3 完成。

已完成：

- 阅读 `AGENTS.md` 新日志要求。
- 阅读 `docs/codex_bagel_repro_plan.md` 中 Task 3 要求。
- 阅读并分析 `app.py`。
- 为解释 `app.py` 调用关系，补充查看 `inferencer.py` 的关键入口。
- 生成 Task 3 记录文件和代码分析日志。

输出文件：

```text
repro_records/task03_20260601_145116/summary_app_py.md
repro_records/task03_20260601_145116/logs/app_py_analysis.log
repro_records/task03_20260601_145116/commands.sh
repro_records/task03_20260601_145116/bugfix_log.md
repro_records/task03_20260601_145116/summary_for_ppt.md
```

## 可用于 PPT 的记录

- `app.py` 是 BAGEL 官方 Gradio UI 的主入口，负责启动参数、模型加载、推理入口和 UI 事件绑定。
- 模型由 LLM、ViT、VAE 三部分配置组合成 `BagelConfig`，权重来自 `models/BAGEL-7B-MoT/ema.safetensors`。
- `mode 1/2/3` 分别对应 bf16 加载、NF4 4bit 量化、INT8 量化。
- tokenizer 使用 `Qwen2Tokenizer.from_pretrained(model_path)`，并通过 `add_special_tokens()` 添加特殊 token。
- `vae_transform = ImageTransform(1024, 512, 16)`，`vit_transform = ImageTransform(980, 224, 14)`。
- 官方 UI 的三个核心入口是 `text_to_image()`、`edit_image()`、`image_understanding()`。
- 文生图和图像编辑最终生成图像；图像理解设置 `understanding_output=True`，最终输出文本。
- `think=True` 会触发额外 thinking prompt，生成或理解前先产生思考/规划文本。
- `cfg_text_scale` 控制文本 prompt 约束强度，`cfg_img_scale` 控制编辑中输入图像保留强度，`num_timesteps` 控制去噪采样步数。
