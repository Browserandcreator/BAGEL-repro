# Task 6 PPT Summary

- 任务：文生图 baseline。
- Prompt：`a small robot sitting at a wooden desk, reading a book under warm light, highly detailed`。
- 参数：`seed=42`、`num_timesteps=30`、`cfg_text_scale=4.0`、`mode=2`、`think=false`。
- 输出文件：`repro_records/task06_20260601_154840/outputs/t2i_baseline.png`。
- 输出规格：1024x1024 RGB PNG，文件大小约 930K。
- 像素检查：RGB 均值 `[90.72, 71.74, 54.57]`，通道范围均为 `0-255`，不是空白图。
- 运行时间：模型加载约 24.71 秒，推理约 136.75 秒，总耗时约 162.26 秒。
- 外层记录总耗时约 170 秒。
- GPU 峰值显存：GPU0 约 11.27GiB，GPU1 约 12.36GiB。
- 任务成功：日志显示 `status=success`。
- 任务结束后无残留推理进程。
- 该任务验证了 Task 5 CLI 可以执行实际文生图生成。
