# BAGEL 复现记录：Task 1 仓库与权重检查

- 已完成仓库结构检查，源码目录存在。
- 关键入口文件存在：`app.py`、`inferencer.py`。
- 关键模块目录存在：`modeling/`、`data/`、`scripts/`、`test_images/`。
- 本地模型目录存在：`models/BAGEL-7B-MoT`。
- 模型配置文件存在：`llm_config.json`、`vit_config.json`、`config.json`。
- tokenizer 文件存在：`tokenizer.json`、`tokenizer_config.json`、`merges.txt`、`vocab.json`。
- `model.safetensors.index.json` 存在，并引用 2 个权重文件。
- 权重完整性检查失败：`ae.safetensors` 缺失，`ema.safetensors` 缺失。
- 隐藏缓存目录中存在约 `11G` 的 `.incomplete` 文件，推测 Hugging Face 下载中断。
- 当前不建议继续启动 UI 或运行推理，需要先补齐模型权重。
- 本任务未修改代码，未删除文件，未运行模型加载。
