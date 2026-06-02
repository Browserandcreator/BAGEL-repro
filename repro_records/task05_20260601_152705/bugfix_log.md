# Bugfix Log

## 问题 1：需要绕过 Gradio 的最小 CLI

### 现象

原始仓库主要通过 `app.py` 启动 Gradio UI，后续基线实验和消融实验需要可记录、可复现、可保存输出的命令行入口。

### 定位

阅读 `app.py` 后确认可复用以下逻辑：

- 模型 config 加载。
- VAE 加载。
- tokenizer 加载和 special token 添加。
- `ImageTransform` 初始化。
- `infer_auto_device_map()` 设备映射。
- `mode=1/2/3` 权重加载。
- `InterleaveInferencer` 初始化。

### 修复方法

新增：

- `scripts/run_bagel_minimal.py`

该脚本只作为 CLI 包装层，不修改核心模型逻辑。

## 问题 2：从 `scripts/` 子目录运行时可能无法导入仓库模块

### 现象

目标脚本位于 `scripts/run_bagel_minimal.py`，直接运行时 Python 的 import 搜索路径可能优先指向 `scripts/`，导致仓库根目录模块导入不稳定。

### 修复方法

在脚本开头加入：

```python
REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))
```

这是 CLI 路径兼容性修复，不涉及模型逻辑。

## 问题 3：默认 Python 环境缺少 `accelerate`

### 现象

执行：

```bash
python scripts/run_bagel_minimal.py --help
```

报错：

```text
ModuleNotFoundError: No module named 'accelerate'
```

### 原因

系统默认 Python 环境缺少 BAGEL 推理依赖；仓库可用环境为 conda 环境 `bagel`。

### 处理

未修改依赖环境。改用：

```bash
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
```

验证成功。

## 问题 4：用户提醒 WebUI 可能仍在运行

### 检查

执行了：

```bash
ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
netstat -ltnp 2>/dev/null | grep ":7860" || true
nvidia-smi
```

### 结果

- 未发现 `app.py` 进程。
- 未发现 `run_bagel_minimal.py` 残留进程。
- 未发现 `7860` 端口监听。
- `nvidia-smi` 显示无活跃 GPU 计算进程。

因此没有执行 kill 操作。
