# PPT Summary

## Task 2：官方 WebUI 启动验证

- 目标：验证 BAGEL 官方 Gradio WebUI 是否能启动。
- 启动方式：使用 `mode 2` 低显存模式。
- 直接运行默认 `python app.py ...` 失败，原因是默认环境缺少 `gradio`。
- 修复方式：切换到已有 conda 环境 `/root/miniconda3/envs/bagel`。
- 成功命令：`/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh`
- WebUI 访问：本机 `http://127.0.0.1:7860` 返回 `HTTP/1.1 200 OK`；远程浏览器使用 `http://<服务器IP>:7860`。
- 用户浏览器端确认：WebUI 可正常显示，可输入提示词、选择任务、调整参数。
- GPU 显存：启动后约 GPU0 4052MiB、GPU1 4140MiB。
- BAGEL 主进程：PID `14402`，约占用 GPU0 4042MiB、GPU1 3462MiB。
- 未修改 BAGEL 模型代码，未修改核心推理逻辑。
- 本次只完成 Task 2，没有执行图像生成或后续实验任务。
