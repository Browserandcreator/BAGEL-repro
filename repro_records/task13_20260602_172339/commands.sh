#!/usr/bin/env bash
set -euo pipefail

# Task13 summary preparation commands and evidence reads.
# The following commands were run from the Windows Codex environment to inspect existing records.

Get-Content -Encoding UTF8 -LiteralPath 'C:\Users\Tiger Xin\diffusion\run\BAGEL-repro\AGENTS.md'
Get-Content -Encoding UTF8 -LiteralPath 'C:\Users\Tiger Xin\diffusion\run\BAGEL-repro\docs\codex_bagel_repro_plan.md'
Get-ChildItem -LiteralPath 'C:\Users\Tiger Xin\diffusion\run\BAGEL-repro\repro_records' -Force
git status --short
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\20260531T080101Z\00_env_check.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\20260531_210418\01_repo_and_weights_check.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\20260601_141533\02_ui_launch.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task03_20260601_145116\summary_app_py.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task04_20260601_152117\summary_inferencer_py.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task05_20260601_152705\minimal_cli.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task06_20260601_154840\03_task_t2i.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task07_20260601_083153\04_task_understanding.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task08_20260601_085406\05_task_editing.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task09\06_ablation_thinking.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task10_20260601_102643\07_ablation_cfg_text_scale.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task11_20260601_204507\08_ablation_cfg_img_scale.md'
Get-Content -Encoding UTF8 -LiteralPath 'repro_records\task12_20260601_211039\09_ablation_timesteps.md'
rg "^=====|^output=|^model_load_seconds=|^inference_seconds=|^total_seconds=|^status=|^wall_seconds=" repro_records/task12_20260601_211039/logs/ablation_timesteps.log
Get-Date -Format yyyyMMdd_HHmmss

# Directory creation attempt. The first command failed in this PowerShell environment
# because New-Item did not accept -LiteralPath here, then -Path succeeded.
New-Item -ItemType Directory -Force -LiteralPath 'repro_records\task13_20260602_172339','repro_records\task13_20260602_172339\logs'
New-Item -ItemType Directory -Force -Path 'repro_records\task13_20260602_172339','repro_records\task13_20260602_172339\logs'

# Codex also visually inspected task12 generated images:
# repro_records/task12_20260601_211039/outputs/steps_10.png
# repro_records/task12_20260601_211039/outputs/steps_30.png
# repro_records/task12_20260601_211039/outputs/steps_50.png
