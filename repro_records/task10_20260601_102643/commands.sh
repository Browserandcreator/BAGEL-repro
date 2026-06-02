#!/usr/bin/env bash
set -euo pipefail
sed -n '1,520p' docs/codex_bagel_repro_plan.md
nvidia-smi
sed -n '1,260p' docs/codex_bagel_repro_plan.md
ls -lah repro_records
find repro_records -maxdepth 1 -type d -name 'task10_*' -print | sort
sed -n '260,520p' docs/codex_bagel_repro_plan.md
ls -R repro_records/task10_20260601_102643
ls -lah repro_records/task10_20260601_102643
sed -n '1,260p' scripts/run_bagel_minimal.py
sed -n '1,160p' repro_records/task10_20260601_102643/commands.sh
sed -n '1,120p' repro_records/task10_20260601_102643/logs/plan_read.log
nvidia-smi
sed -n '260,620p' scripts/run_bagel_minimal.py
ls -lah scripts
git status --short
bash -n repro_records/task10_20260601_102643/run_task10_cfg_text_ablation.sh
sed -n '1,220p' repro_records/task10_20260601_102643/run_task10_cfg_text_ablation.sh
sed -n '1,240p' repro_records/task10_20260601_102643/07_ablation_cfg_text_scale.md
ls -lah repro_records/task10_20260601_102643 repro_records/task10_20260601_102643/logs repro_records/task10_20260601_102643/outputs
sed -n '260,360p' docs/codex_bagel_repro_plan.md
ls -lah repro_records/task10_20260601_102643/outputs
tail -240 repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
file repro_records/task10_20260601_102643/outputs/cfg_text_1.png repro_records/task10_20260601_102643/outputs/cfg_text_4.png repro_records/task10_20260601_102643/outputs/cfg_text_8.png
# Continue task10 after manual run
sed -n '260,360p' docs/codex_bagel_repro_plan.md
ls -lah repro_records/task10_20260601_102643/outputs
tail -240 repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
file repro_records/task10_20260601_102643/outputs/cfg_text_1.png repro_records/task10_20260601_102643/outputs/cfg_text_4.png repro_records/task10_20260601_102643/outputs/cfg_text_8.png
grep -E '===== cfg_text_scale=|output=|model_load_seconds=|inference_seconds=|total_seconds=|gpu_memory_after_load=|gpu_memory_after_inference=|wall_seconds=|status=success|status=completed' repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
nvidia-smi
ls -lh repro_records/task10_20260601_102643/outputs/*.png
python -c "from pathlib import Path; from PIL import Image, ImageStat; [print(p) for p in sorted(Path(\repro_records/task10_20260601_102643/outputs\).glob(\cfg_text_*.png\))]"
python - <<PY
from pathlib import Path
from PIL import Image, ImageStat
for p in sorted(Path("repro_records/task10_20260601_102643/outputs").glob("cfg_text_*.png")):
    im = Image.open(p).convert("RGB")
    stat = ImageStat.Stat(im)
    mean = tuple(round(v, 2) for v in stat.mean)
    std = tuple(round(v, 2) for v in stat.stddev)
    print(f"{p}: size={im.size} mean_rgb={mean} std_rgb={std} extrema={im.getextrema()}")
PY
head -80 repro_records/task10_20260601_102643/logs/ablation_cfg_text.log
# Report completion
cat > repro_records/task10_20260601_102643/07_ablation_cfg_text_scale.md <<EOF
# ... final Task 10 report written in Chinese ...
EOF
# Final verification
sed -n '1,260p' repro_records/task10_20260601_102643/07_ablation_cfg_text_scale.md
ls -lah repro_records/task10_20260601_102643 repro_records/task10_20260601_102643/logs repro_records/task10_20260601_102643/outputs
tail -40 repro_records/task10_20260601_102643/commands.sh  # failed in sandbox with bwrap namespace error
