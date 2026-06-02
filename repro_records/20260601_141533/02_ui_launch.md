# Task 2: Launch Official UI

## 目标

验证 BAGEL 官方 Gradio WebUI 是否可以启动，并记录启动模式、访问链接、加载时间、GPU 显存占用、警告和错误。

计划文件：`docs/codex_bagel_repro_plan.md`

本次只执行 Task 2，没有执行图像生成或后续 baseline/ablation 任务。

## 执行命令

记录目录：

```bash
repro_records/20260601_141533/
```

主要命令：

```bash
pwd
ss -ltnp | grep 7860 || true
nvidia-smi
python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
lsof -iTCP:7860 -sTCP:LISTEN || true
/root/miniconda3/bin/conda env list
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
curl -I --max-time 5 http://127.0.0.1:7860 || true
ps -ef | grep -E 'app.py|conda run -n bagel' | grep -v grep
tail -200 repro_records/20260601_141533/logs/ui_launch.log
```

完整命令记录见：

```bash
repro_records/20260601_141533/commands.sh
```

原始日志见：

```bash
repro_records/20260601_141533/logs/ui_launch.log
```

## 关键输出

第一次直接使用默认 Python 启动失败：

```text
Traceback (most recent call last):
  File "/root/autodl-tmp/BAGEL/app.py", line 1, in <module>
    import gradio as gr
ModuleNotFoundError: No module named 'gradio'
```

随后检查 conda 环境，确认存在 `bagel` 环境：

```text
bagel                    /root/miniconda3/envs/bagel
```

使用 `bagel` 环境重试：

```bash
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
```

用户浏览器端确认 WebUI 已正常显示，并且可以输入提示词、选择任务、调整参数。

本机 HTTP 检查确认 WebUI 端口可访问：

```text
HTTP/1.1 200 OK
server: uvicorn
content-length: 84561
content-type: text/html; charset=utf-8
```

访问链接：

```text
本机: http://127.0.0.1:7860
远程浏览器: http://<服务器IP>:7860
服务参数: --server_name 0.0.0.0 --server_port 7860
```

进程状态：

```text
python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
主进程 PID: 14402
```

GPU 显存状态，记录时间为 2026-06-01 14:37:13：

```text
GPU0: 4052MiB / 24564MiB
GPU1: 4140MiB / 24564MiB

进程 14402:
GPU0: 4042MiB
GPU1: 3462MiB
```

加载时间：

```text
conda bagel 环境启动时间: 2026-06-01T06:21:29Z
浏览器端确认可用时间: 约 2026-06-01 14:23 UTC+8 附近
估计加载耗时: 约 2 分钟
```

说明：由于 `conda run` 输出缓冲，`ui_launch.log` 没有自动捕获 Gradio 的 `Running on ...` 行，因此加载耗时为基于启动时间、浏览器确认时间和 GPU/进程检查时间的近似值。

## 报错 / 警告

1. 默认 Python 环境缺少 `gradio`。

```text
ModuleNotFoundError: No module named 'gradio'
```

2. 系统缺少端口检查工具。

```text
/bin/bash: line 1: ss: command not found
/bin/bash: line 1: lsof: command not found
```

3. `conda run` 启动后日志没有及时刷出 Gradio URL。

这不是 WebUI 失败，而是自动检测脚本没有从日志中捕获到 URL。最终通过用户浏览器端确认和 `curl -I http://127.0.0.1:7860` 的 `HTTP/1.1 200 OK` 验证 WebUI 已可访问。

## 修复尝试

没有修改 BAGEL 模型代码，也没有修改核心推理逻辑。

低风险处理：

- 发现默认 Python 缺少 `gradio` 后，切换到已有 conda 环境 `bagel`。
- 使用 `curl -I http://127.0.0.1:7860` 替代缺失的 `ss` / `lsof` 做 WebUI 可访问性检查。
- 将进程状态和 GPU 显存追加到 `logs/ui_launch.log`。

## 结果

Task 2 成功。

成功模式：

```text
mode 2
```

成功命令：

```bash
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
```

WebUI 状态：

```text
已启动，可访问，可在浏览器中输入提示词、选择任务、调整参数。
```

输出文件：

```text
repro_records/20260601_141533/02_ui_launch.md
repro_records/20260601_141533/logs/ui_launch.log
repro_records/20260601_141533/commands.sh
repro_records/20260601_141533/bugfix_log.md
repro_records/20260601_141533/summary_for_ppt.md
```

## 可用于 PPT 的记录

- 官方 Gradio WebUI 可在 `mode 2` 下启动成功。
- 默认 Python 环境缺少 `gradio`，需要使用 `/root/miniconda3/envs/bagel`。
- WebUI 监听 `0.0.0.0:7860`，本机 `http://127.0.0.1:7860` 返回 `HTTP/1.1 200 OK`。
- 启动后 GPU 显存约为 GPU0 4052MiB、GPU1 4140MiB。
- BAGEL 主进程 PID `14402`，占用约 GPU0 4042MiB、GPU1 3462MiB。
- 本次没有执行生成图片任务；Task 2 仅验证 UI 启动。
