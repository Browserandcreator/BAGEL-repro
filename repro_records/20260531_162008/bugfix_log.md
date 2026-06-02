# Bugfix Log

## Task 1：Repository and Weight Check

### 问题现象

权重完整性检查发现：

```text
MISSING models/BAGEL-7B-MoT/ae.safetensors
MISSING models/BAGEL-7B-MoT/ema.safetensors
```

解析 `models/BAGEL-7B-MoT/model.safetensors.index.json` 后确认：

```text
shard_count_in_index: 2
missing_shard_count: 2
MISSING ae.safetensors
MISSING ema.safetensors
```

同时，隐藏缓存目录中存在未完成下载文件：

```text
models/BAGEL-7B-MoT/.cache/huggingface/download/*.incomplete
```

其中一个 `.incomplete` 文件约 `11G`。

### 原因分析

当前模型目录内配置文件和 tokenizer 文件存在，但 index 引用的两个 safetensors 权重文件不存在。

`du -sh models/BAGEL-7B-MoT` 显示目录占用约 `11G`，主要空间来自 `.cache/huggingface/download/*.incomplete`，说明此前下载很可能中断，权重文件尚未完成落盘。

### 修复方法

本任务未执行修复。

原因：

- 不删除 `.incomplete` 文件，避免破坏可恢复下载状态。
- 不覆盖现有模型目录，避免误删用户已有文件。
- 是否继续下载、断点续传或重新下载权重，需要用户确认后再执行。

### 影响

在 `ae.safetensors` 和 `ema.safetensors` 补齐前，Task 2 的 UI 启动预计会在模型加载阶段失败。

### 修改记录

没有修改代码。
没有修改模型文件。
没有删除或覆盖任何 checkpoint、日志或输出文件。
