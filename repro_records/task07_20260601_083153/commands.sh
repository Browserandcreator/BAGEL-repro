#!/usr/bin/env bash
set -euo pipefail
sed -n '1,520p' docs/codex_bagel_repro_plan.md
find . -maxdepth 4 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort | head -100
ls -R repro_records/task07_20260601_083153
python scripts/run_bagel_minimal.py --help
nvidia-smi
file test_images/meme.jpg test_images/octupusy.jpg test_images/women.jpg assets/teaser.webp
/root/miniconda3/bin/conda env list
which python
python -V
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
/usr/bin/time -v /root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task understand --image test_images/meme.jpg --prompt "Describe this image in detail." --output repro_records/task07_20260601_083153/outputs/understanding_baseline.txt --mode 2
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task understand --image test_images/meme.jpg --prompt "Describe this image in detail." --output repro_records/task07_20260601_083153/outputs/understanding_baseline.txt --mode 2
ps -ef | grep -E "run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
nvidia-smi
nvidia-smi
sed -n '1,200p' repro_records/task07_20260601_083153/outputs/understanding_baseline.txt
find repro_records/task07_20260601_083153 -maxdepth 3 -type f | sort
ls -lah repro_records/task07_20260601_083153 repro_records/task07_20260601_083153/logs repro_records/task07_20260601_083153/outputs
sed -n '1,260p' repro_records/task07_20260601_083153/04_task_understanding.md
