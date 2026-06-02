#!/usr/bin/env bash
set -euo pipefail
sed -n 1,220p AGENTS.md
sed -n 330,390p docs/codex_bagel_repro_plan.md
sed -n 1,220p scripts/run_bagel_minimal.py
ls -lah repro_records
mkdir -p repro_records/task12_20260601_211039/logs repro_records/task12_20260601_211039/outputs
cat > repro_records/task12_20260601_211039/commands.sh <<EOF
# initial commands written
EOF
cat > repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh <<EOF
# task12 manual GPU script written
EOF
chmod +x repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
cat > repro_records/task12_20260601_211039/09_ablation_timesteps.md <<EOF
# task12 placeholder report written
EOF
cat > repro_records/task12_20260601_211039/logs/ablation_timesteps.log <<EOF
# task12 placeholder log written
EOF
bash -n repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
sed -n '1,240p' repro_records/task12_20260601_211039/run_task12_timesteps_ablation.sh
sed -n '1,220p' repro_records/task12_20260601_211039/09_ablation_timesteps.md
ls -lah repro_records/task12_20260601_211039 repro_records/task12_20260601_211039/logs repro_records/task12_20260601_211039/outputs
nvidia-smi
# Continue/finalize task12 after manual run
ps -ef
ls -lah repro_records/task12_20260601_211039/outputs repro_records/task12_20260601_211039/logs
file repro_records/task12_20260601_211039/outputs/steps_10.png repro_records/task12_20260601_211039/outputs/steps_30.png repro_records/task12_20260601_211039/outputs/steps_50.png
grep -E '^task=12|^start_utc=|^prompt=|^seed=|^cfg_text_scale=|^mode=|^===== num_timesteps=|^output=|^task=t2i|^model_load_seconds=|^inference_seconds=|^total_seconds=|^gpu_memory_after_load=|^gpu_memory_after_inference=|^status=success|^wall_seconds=|^end_utc=|^status=completed' repro_records/task12_20260601_211039/logs/ablation_timesteps.log
python - <<PY
# image statistics for steps outputs
PY
