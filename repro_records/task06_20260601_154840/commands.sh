#!/usr/bin/env bash
set -euo pipefail

sed -n '1,520p' docs/codex_bagel_repro_plan.md
sed -n '1,260p' AGENTS.md
sed -n '1,260p' scripts/run_bagel_minimal.py
ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
netstat -ltnp 2>/dev/null | grep ":7860" || true
nvidia-smi
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --model_path models/BAGEL-7B-MoT --mode 2 --task text-to-image --prompt "a small robot sitting at a wooden desk, reading a book under warm light, highly detailed" --output repro_records/task06_20260601_154840/outputs/t2i_baseline.png --seed 42 --think false --num_timesteps 30 --cfg_text_scale 4.0 --cfg_img_scale 1.5 --cfg_interval 0.4 --timestep_shift 3.0
ls -lah repro_records/task06_20260601_154840/outputs
file repro_records/task06_20260601_154840/outputs/t2i_baseline.png
tail -160 repro_records/task06_20260601_154840/logs/t2i_baseline.log
ps -ef | grep -E "app.py|run_bagel_minimal.py|conda run -n bagel" | grep -v grep || true
nvidia-smi
/root/miniconda3/bin/conda run -n bagel python -c "from PIL import Image, ImageStat; p=\"repro_records/task06_20260601_154840/outputs/t2i_baseline.png\"; im=Image.open(p); stat=ImageStat.Stat(im); print({\"size\": im.size, \"mode\": im.mode, \"mean\": [round(x, 2) for x in stat.mean], \"extrema\": im.getextrema()})"
ls -la repro_records/task06_20260601_154840
ls -la repro_records/task06_20260601_154840/logs
ls -la repro_records/task06_20260601_154840/outputs
sed -n '1,260p' repro_records/task06_20260601_154840/03_task_t2i.md
sed -n '1,160p' repro_records/task06_20260601_154840/summary_for_ppt.md
sed -n '1,180p' repro_records/task06_20260601_154840/bugfix_log.md
