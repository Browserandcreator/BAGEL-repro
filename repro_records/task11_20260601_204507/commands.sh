#!/usr/bin/env bash
set -euo pipefail
sed -n 1,260p AGENTS.md
sed -n 300,380p docs/codex_bagel_repro_plan.md
ls -lah repro_records
sed -n 1,220p repro_records/task08_20260601_085406/05_task_editing.md
ls -lah repro_records/task08_20260601_085406 repro_records/task08_20260601_085406/outputs repro_records/task08_20260601_085406/logs
sed -n 1,220p scripts/run_bagel_minimal.py
sed -n 300,350p docs/codex_bagel_repro_plan.md
mkdir -p repro_records/task11_20260601_204507/logs repro_records/task11_20260601_204507/outputs
cat > repro_records/task11_20260601_204507/commands.sh <<EOF
# initial commands written
EOF
cat > repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh <<EOF
# task11 manual GPU script written
EOF
chmod +x repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh
cat > repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md <<EOF
# task11 placeholder report written
EOF
cat > repro_records/task11_20260601_204507/logs/ablation_cfg_img.log <<EOF
# task11 placeholder log written
EOF
bash -n repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh
sed -n '1,240p' repro_records/task11_20260601_204507/run_task11_cfg_img_ablation.sh
sed -n '1,220p' repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md
file test_images/women.jpg
ls -lah repro_records/task11_20260601_204507 repro_records/task11_20260601_204507/logs repro_records/task11_20260601_204507/outputs
# Continue task11 after manual run
ls -lah repro_records/task11_20260601_204507/outputs
tail -240 repro_records/task11_20260601_204507/logs/ablation_cfg_img.log
file repro_records/task11_20260601_204507/outputs/cfg_img_1.png repro_records/task11_20260601_204507/outputs/cfg_img_2.png repro_records/task11_20260601_204507/outputs/cfg_img_4.png
nvidia-smi
grep -E '^task=11|^start_utc=|^image_path=|^prompt=|^seed=|^num_timesteps=|^cfg_text_scale=|^mode=|^===== cfg_img_scale=|^output=|^task=edit|^input_image=|^model_load_seconds=|^inference_seconds=|^total_seconds=|^gpu_memory_after_load=|^gpu_memory_after_inference=|^status=success|^wall_seconds=|^end_utc=|^status=completed' repro_records/task11_20260601_204507/logs/ablation_cfg_img.log
python - <<PY
# image statistics and diff from input
PY
# Final report completion
ps -ef
sed -n '1,260p' repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md
ls -lah repro_records/task11_20260601_204507/outputs repro_records/task11_20260601_204507/logs
cat > repro_records/task11_20260601_204507/08_ablation_cfg_img_scale.md <<EOF
# ... final Task 11 report written in Chinese ...
EOF
