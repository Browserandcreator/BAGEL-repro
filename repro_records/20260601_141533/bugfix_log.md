# Bugfix Log

## Task 2: Launch Official UI

### 问题 1：默认 Python 环境缺少 `gradio`

现象：

```text
Traceback (most recent call last):
  File "/root/autodl-tmp/BAGEL/app.py", line 1, in <module>
    import gradio as gr
ModuleNotFoundError: No module named 'gradio'
```

原因分析：

直接运行 `python app.py ...` 使用的是默认 Python 环境，该环境没有安装 `gradio`。这属于运行环境选择问题，不是 BAGEL 模型代码问题。

处理方法：

检查 conda 环境后发现已有 `bagel` 环境：

```text
bagel                    /root/miniconda3/envs/bagel
```

改用：

```bash
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
```

结果：

WebUI 成功启动，用户浏览器端确认可以输入提示词、选择任务并调整参数。

代码修改：

无。没有修改核心模型逻辑，也没有修改 `app.py`。

### 问题 2：端口检查工具缺失

现象：

```text
/bin/bash: line 1: ss: command not found
/bin/bash: line 1: lsof: command not found
```

原因分析：

当前环境没有安装 `ss` 和 `lsof`，不能用这两个工具检查 7860 端口监听状态。

处理方法：

改用 HTTP 探测：

```bash
curl -I --max-time 5 http://127.0.0.1:7860 || true
```

结果：

```text
HTTP/1.1 200 OK
server: uvicorn
content-type: text/html; charset=utf-8
```

说明 WebUI 端口可访问。

代码修改：

无。

### 问题 3：日志未自动捕获 Gradio URL

现象：

`conda run -n bagel python app.py ...` 启动后，WebUI 实际可用，但 `logs/ui_launch.log` 中没有及时出现 Gradio 的 `Running on ...` 行。

原因分析：

推测与 `conda run` 和子进程 stdout/stderr 缓冲有关。该问题影响自动检测脚本判断，不影响 WebUI 实际启动。

处理方法：

使用三类证据确认启动成功：

- 用户浏览器端确认 WebUI 可用。
- `ps` 显示 `python app.py --mode 2 ...` 进程仍在运行。
- `curl -I http://127.0.0.1:7860` 返回 `HTTP/1.1 200 OK`。

代码修改：

无。
