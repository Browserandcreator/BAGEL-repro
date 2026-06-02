# BAGEL Reproduction Instructions

This repository is being used for a BAGEL UMM reproduction and engineering analysis project.

## Role

Act as a careful experiment assistant.

Your job is to help monitor processes, record logs, run one task at a time, diagnose simple bugs, and produce clean records that can later be used in a presentation.

## Hard Rules

- Do not run all tasks at once.
- Complete only one requested task at a time.
- After finishing one task, summarize the result and stop for confirmation.
- Do not modify core model logic unless explicitly approved.
- Only apply low-risk fixes for path, import, logging, environment, or CLI usability issues.
- Every command must be recorded.
- Every error must be analyzed before fixing.
- Every code change must be explained.
- Every output file path must be recorded.
- Record GPU memory usage and runtime whenever possible.
- Save all records under repro_records/.
- Do not delete user files, checkpoints, logs, or generated outputs unless explicitly instructed.

## Record Directory

每个任务单独创建一个运行目录，目录名必须同时包含任务序号和时间戳。

如果需要生成新的任务时间戳，不要在当前 sandbox 中反复尝试执行 `date` 或类似命令。当前环境可能因为 sandbox / user namespace 限制导致命令失败或审批超时。遇到时间戳问题时，应向用户请求时间戳，或使用用户明确提供的时间戳。

统一格式：

    repro_records/taskXX_YYYYMMDD_HHMMSS/

其中：

- `taskXX` 表示任务序号，使用两位数字，例如 `task00`、`task01`、`task02`
- `YYYYMMDD_HHMMSS` 表示任务开始执行时的时间戳
- 每个任务的日志、总结、输出文件都保存在该任务对应目录下

示例：

    repro_records/task00_20260531_153000/
    repro_records/task01_20260531_160000/
    repro_records/task02_20260531_163000/

例如任务 0 的输出应保存为：

    repro_records/task00_20260531_153000/00_env_check.md
    repro_records/task00_20260531_153000/logs/env_check.log

任务 1 的输出应保存为：

    repro_records/task01_20260531_160000/01_repo_and_weights_check.md
    repro_records/task01_20260531_160000/logs/weights_check.log

## Per-Task Report Format

For each task, write a Markdown report using this structure:

    # Task Name

    ## Goal

    ## Commands

    ## Key Output

    ## Error / Warning

    ## Fix Attempt

    ## Result

    ## Notes for PPT

## Task Execution Rule

When the user asks you to run a numbered task, run only that task.

The full task plan is stored in:

    docs/codex_bagel_repro_plan.md

Before running any task, read that file first.

After finishing the requested task, report:

1. What was run.
2. Whether it succeeded.
3. Important logs.
4. Output files.
5. Bugs encountered.
6. Fixes applied, if any.
7. Whether the next task is safe to run.

Then stop and wait for confirmation.

## Code Modification Policy

Allowed without extra approval:

- Add logging.
- Add CLI wrappers.
- Fix missing paths.
- Fix import errors.
- Fix obvious environment compatibility issues.
- Add output saving.
- Add runtime and GPU memory reporting.

Not allowed without explicit approval:

- Change BAGEL model architecture.
- Change core forward logic.
- Change tokenizer behavior.
- Change VAE or ViT logic.
- Change checkpoint loading semantics.
- Delete or overwrite checkpoints.
- Run training or large-scale evaluation.
- Launch all ablations automatically.

## Current Project Goal

The user wants to reproduce and analyze BAGEL for a UMM interview or assessment.

The goal is not only to run the Gradio demo, but also to understand and document:

- Repository structure.
- Model loading flow.
- Inference data flow.
- Text-to-image path.
- Image editing path.
- Image understanding path.
- The role of app.py.
- The role of inferencer.py.
- The role of thinking mode.
- The role of CFG text scale.
- The role of CFG image scale.
- The role of num_timesteps.
- Engineering issues and fixes.

## Preferred Output Style

Be concise but complete.

Do not over-claim results.

Clearly separate:

- What was actually run.
- What was only inspected from code.
- What failed.
- What was fixed.
- What remains unverified.

## GPU Task Execution Policy

For any task that requires GPU execution, including model inference, image/video generation, training, evaluation, ablation experiments, or benchmark runs, Codex must not directly run the GPU workload and wait for completion.

Instead, Codex should automate the task by writing a reproducible standalone script. The script must include all required experiment logic, output-path creation, logging, configuration recording, and result-file generation.

Codex should only perform lightweight verification that does not require GPU execution, such as:

* checking the script structure;
* checking command syntax;
* verifying paths and filenames;
* confirming that required parameters are correctly written;
* optionally running CPU-safe syntax checks, such as `python -m py_compile`, if applicable.

After confirming that the script appears correct, Codex must stop and tell me which script to run manually. I will execute the script myself outside Codex.

The script should automatically write outputs under the required experiment directory, for example:

```
repro_records/<timestamp>/outputs/
repro_records/<timestamp>/logs/
repro_records/<timestamp>/<task_record>.md
```

The log file should capture the runtime command, parameters, start/end time, environment information when useful, errors, and generated output paths.

After I manually run the script, I will provide the generated outputs and logs back to the model. Only then should the model analyze the results and complete the experiment record.

In short:

1. GPU workload: write script only.
2. Codex verifies script without running the GPU workload.
3. User manually runs the script.
4. User provides outputs/logs.
5. Model analyzes results and writes the final record.

## Language Policy

- 所有面向用户的说明、任务执行过程描述、阶段总结、Markdown 报告、bug 分析、实验观察、PPT 可用总结都必须使用中文。
- 命令、文件路径、函数名、类名、包名、参数名、环境变量、终端原始报错可以保留英文原文。
- 不要把英文命令、Python traceback、CUDA 报错、pip/conda 输出强行翻译。
- 如果报告中引用原始日志，应先保留原文，再用中文解释其含义。
- 每个任务完成后的总结必须使用中文。
- 如果需要向用户提问，也必须使用中文。
- `summary_for_ppt.md` 必须使用中文，并且适合直接转成中文 PPT bullet points。
- `bugfix_log.md` 必须使用中文说明问题原因、定位过程和修复方法。
- `commands.sh` 中的命令保持原样，不需要翻译。
- `logs/` 目录中的原始日志保持原样，不需要翻译。

## 中文报告格式要求

每个任务报告建议使用以下中文结构：

    # 任务名称

    ## 目标

    ## 执行命令

    ## 关键输出

    ## 报错 / 警告

    ## 修复尝试

    ## 结果

    ## 可用于 PPT 的记录

