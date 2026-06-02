#!/usr/bin/env bash
set -euo pipefail

sed -n '1,260p' AGENTS.md
sed -n '1,520p' docs/codex_bagel_repro_plan.md
sed -n '1,260p' app.py
sed -n '261,620p' app.py
sed -n '1,360p' inferencer.py
ls -la scripts || true
find . -maxdepth 3 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort | head -100
ls -lah models/BAGEL-7B-MoT || true
nvidia-smi
sed -n '1,220p' modeling/autoencoder.py
grep -R "def load_ae" -n modeling data | head -20
python -m py_compile scripts/run_bagel_minimal.py
python scripts/run_bagel_minimal.py --help
/root/miniconda3/bin/conda env list
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --model_path models/BAGEL-7B-MoT --mode 2 --task understand --image test_images/meme.jpg --prompt "Describe this image briefly." --output repro_records/task05_20260601_152705/outputs/smoke_understanding.txt --seed 42 --think false --max_think_token_n 64
ls -la repro_records/task05_20260601_152705/outputs
tail -120 repro_records/task05_20260601_152705/logs/minimal_cli.log
sed -n '1,120p' repro_records/task05_20260601_152705/outputs/smoke_understanding.txt
git status --short
lsof -iTCP:7860 -sTCP:LISTEN || true
ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
nvidia-smi
ss -ltnp | grep ":7860" || true
netstat -ltnp 2>/dev/null | grep ":7860" || true
ls -la repro_records/task05_20260601_152705
ls -la repro_records/task05_20260601_152705/logs
ls -la repro_records/task05_20260601_152705/outputs
sed -n '1,260p' repro_records/task05_20260601_152705/minimal_cli.md
sed -n '1,220p' repro_records/task05_20260601_152705/bugfix_log.md
sed -n '1,160p' repro_records/task05_20260601_152705/summary_for_ppt.md
