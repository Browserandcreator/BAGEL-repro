# Task 5 PPT Summary

- 新增最小 CLI：`scripts/run_bagel_minimal.py`。
- 目标：绕过 Gradio，直接调用 BAGEL 官方推理封装 `InterleaveInferencer`。
- 支持任务：文生图、图像理解、图像编辑。
- 关键参数：`--model_path`、`--mode`、`--task`、`--image`、`--prompt`、`--output`、`--seed`、`--think`、`--num_timesteps`、`--cfg_text_scale`、`--cfg_img_scale`、`--cfg_interval`、`--timestep_shift`。
- 复用 `app.py` 的模型加载流程：config、VAE、tokenizer、special tokens、VAE/ViT transform、device map、NF4/INT8/full checkpoint 加载。
- Smoke test：`mode=2`、`task=understand`、输入 `test_images/meme.jpg`。
- Smoke test 输出：`repro_records/task05_20260601_152705/outputs/smoke_understanding.txt`。
- Smoke test 成功：`status=success`。
- 运行时间：模型加载约 24.65 秒，推理约 46.10 秒，总耗时约 70.82 秒；外层记录约 78 秒。
- GPU 记录：PyTorch 峰值显存 GPU0 约 11.27GiB，GPU1 约 12.36GiB。
- 环境注意：默认系统 Python 缺少 `accelerate`，需要使用 `conda run -n bagel python ...`。
- 用户提醒后已检查：没有残留 WebUI/CLI 进程，`7860` 端口未发现监听，因此未 kill 进程。
- 未验证：文生图、图像编辑、`mode=1`、`mode=3`、thinking mode 输出质量。
