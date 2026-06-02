#!/usr/bin/env bash
set -euo pipefail

# Task 2: Launch Official UI
pwd
sed -n '1,240p' docs/codex_bagel_repro_plan.md
mkdir -p repro_records/20260531_212613/logs repro_records/20260531_212613/outputs
date +%F\ %T\ %Z
pwd
/root/miniconda3/bin/conda run -n bagel python -V
nvidia-smi
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
