#!/usr/bin/env bash
set -euo pipefail
sed -n '1,520p' docs/codex_bagel_repro_plan.md
find . -maxdepth 4 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort | head -100
file test_images/meme.jpg test_images/octupusy.jpg test_images/women.jpg assets/teaser.webp
nvidia-smi
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task edit --image test_images/women.jpg --prompt "change the background into a subway station while keeping the main subject unchanged" --output repro_records/task08_20260601_085406/outputs/edit_baseline.png --mode 2 --num_timesteps 30 --cfg_text_scale 4.0 --cfg_img_scale 2.0 --seed 42
find repro_records/task08_20260601_085406 -maxdepth 3 -type f | sort
nvidia-smi
file repro_records/task08_20260601_085406/outputs/edit_baseline.png
