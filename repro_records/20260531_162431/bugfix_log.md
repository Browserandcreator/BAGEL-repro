# Bugfix Log

## Task 1 记录

### 问题 1：默认 sandbox 无法执行命令

原始报错：

```text
bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces.
```

原因分析：

- 该错误来自命令执行环境的 sandbox 初始化阶段。
- 当前系统或容器不允许创建非特权 user namespace。
- 这不是 BAGEL 仓库代码、Python 环境或模型权重本身的问题。

处理方法：

- 使用外部执行权限重新运行只读检查命令。
- 将该环境限制记录到 Task 1 报告中。

是否修改代码：

- 否。

### 问题 2：模型权重疑似未下载完整

现象：

```text
MISSING models/BAGEL-7B-MoT/ae.safetensors
MISSING models/BAGEL-7B-MoT/ema.safetensors
```

并且 `.safetensors` 搜索没有返回任何完整权重文件。

进一步检查：

```text
11G models/BAGEL-7B-MoT/.cache/huggingface/download/...incomplete
```

原因分析：

- `models/BAGEL-7B-MoT` 目录存在，配置和 tokenizer 文件存在。
- 大体积内容主要是 Hugging Face 下载缓存中的 `.incomplete` 文件。
- 这说明下载可能中断，当前不能认为权重已完整可用。

处理方法：

- 本任务只做检查，未自动重新下载。
- 未删除 `.incomplete` 文件。
- 未修改 checkpoint 加载逻辑。

是否修改代码：

- 否。

