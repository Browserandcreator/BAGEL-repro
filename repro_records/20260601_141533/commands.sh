#!/usr/bin/env bash
set -euo pipefail

pwd
ss -ltnp | grep 7860 || true
nvidia-smi
python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
lsof -iTCP:7860 -sTCP:LISTEN || true
# Controlled wrapper: start app.py, poll logs for Gradio URL, record runtime/GPU, then stop process
/root/miniconda3/bin/conda env list
/root/miniconda3/bin/conda run -n bagel python app.py --mode 2 --server_name 0.0.0.0 --server_port 7860 --zh
curl -I --max-time 5 http://127.0.0.1:7860 || true
ps -ef | grep -E 'app.py|conda run -n bagel' | grep -v grep
tail -200 repro_records/20260601_141533/logs/ui_launch.log
