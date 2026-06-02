#!/usr/bin/env bash
set -euo pipefail

RECORD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${RECORD_DIR}/../.." && pwd)"
LOG_PATH="${RECORD_DIR}/logs/ablation_timesteps.log"
OUTPUT_DIR="${RECORD_DIR}/outputs"

mkdir -p "${OUTPUT_DIR}" "$(dirname "${LOG_PATH}")"

PROMPT="a detailed cyberpunk street at night with neon lights and rain"
SEED=42
CFG_TEXT_SCALE=4.0
MODE=2
THINK=false
MODEL_PATH="${MODEL_PATH:-models/BAGEL-7B-MoT}"

if [[ -n "${PYTHON_BIN:-}" ]]; then
  PYTHON_CMD=("${PYTHON_BIN}")
elif [[ -x /root/miniconda3/bin/conda ]]; then
  PYTHON_CMD=(/root/miniconda3/bin/conda run -n bagel python)
else
  PYTHON_CMD=(python)
fi

{
  echo "task=12 num_timesteps ablation"
  echo "start_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "repo_root=${REPO_ROOT}"
  echo "record_dir=${RECORD_DIR}"
  echo "python_cmd=${PYTHON_CMD[*]}"
  echo "model_path=${MODEL_PATH}"
  echo "prompt=${PROMPT}"
  echo "seed=${SEED}"
  echo "cfg_text_scale=${CFG_TEXT_SCALE}"
  echo "mode=${MODE}"
  echo "think=${THINK}"
  echo
} > "${LOG_PATH}"

cd "${REPO_ROOT}"

run_one() {
  local steps="$1"
  local output_path="${OUTPUT_DIR}/steps_${steps}.png"

  {
    echo "===== num_timesteps=${steps} ====="
    echo "output=${output_path}"
    echo "before_gpu:"
    nvidia-smi || true
    echo "command=${PYTHON_CMD[*]} scripts/run_bagel_minimal.py --task t2i --prompt ${PROMPT} --output ${output_path} --mode ${MODE} --seed ${SEED} --think ${THINK} --num_timesteps ${steps} --cfg_text_scale ${CFG_TEXT_SCALE} --model_path ${MODEL_PATH}"
  } >> "${LOG_PATH}"

  local start_s
  start_s="$(date +%s)"

  "${PYTHON_CMD[@]}" scripts/run_bagel_minimal.py \
    --task t2i \
    --prompt "${PROMPT}" \
    --output "${output_path}" \
    --mode "${MODE}" \
    --seed "${SEED}" \
    --think "${THINK}" \
    --num_timesteps "${steps}" \
    --cfg_text_scale "${CFG_TEXT_SCALE}" \
    --model_path "${MODEL_PATH}" \
    >> "${LOG_PATH}" 2>&1

  local end_s
  end_s="$(date +%s)"

  {
    echo "wall_seconds=$((end_s - start_s))"
    echo "after_gpu:"
    nvidia-smi || true
    echo
  } >> "${LOG_PATH}"
}

run_one "10"
run_one "30"
run_one "50"

{
  echo "end_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "status=completed"
  echo "outputs:"
  ls -lah "${OUTPUT_DIR}"/steps_*.png
} >> "${LOG_PATH}"
