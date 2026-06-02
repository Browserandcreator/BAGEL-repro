#!/usr/bin/env bash
set -euo pipefail
sed -n '1,520p' docs/codex_bagel_repro_plan.md
nvidia-smi
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --help
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task text-to-image --prompt a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby --output repro_records/task09/outputs/think_false.png --mode 2 --seed 42 --num_timesteps 30 --cfg_text_scale 4.0 --think false
/root/miniconda3/bin/conda run -n bagel python scripts/run_bagel_minimal.py --task text-to-image --prompt a robot chef cooking noodles in a futuristic kitchen, with a cat watching nearby --output repro_records/task09/outputs/think_true.png --mode 2 --seed 42 --num_timesteps 30 --cfg_text_scale 4.0 --think true
cp repro_records/task09/outputs/think_true.png.txt repro_records/task09/outputs/think_true_text.txt
nvidia-smi
file repro_records/task09/outputs/think_false.png repro_records/task09/outputs/think_true.png repro_records/task09/outputs/think_true_text.txt
find repro_records/task09 -maxdepth 3 -type f | sort
sed -n '1,120p' repro_records/task09/outputs/think_true_text.txt
find repro_records/task09 -maxdepth 3 -type f | sort
sed -n '1,260p' repro_records/task09/06_ablation_thinking.md
