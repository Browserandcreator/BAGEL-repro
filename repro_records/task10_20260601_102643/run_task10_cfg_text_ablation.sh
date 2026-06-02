#!/usr/bin/env bash
set -euo pipefail

RECORD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${RECORD_DIR}/../.." && pwd)"
LOG_PATH="${RECORD_DIR}/logs/ablation_cfg_text.log"
OUTPUT_DIR="${RECORD_DIR}/outputs"

mkdir -p "${OUTPUT_DIR}" "$(dirname "${LOG_PATH}")"

PROMPT="a blue glass castle floating above the ocean at sunset"
SEED=42
NUM_TIMESTEPS=30
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
  echo "task=10 cfg_text_scale ablation"
  echo "start_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "repo_root=${REPO_ROOT}"
  echo "record_dir=${RECORD_DIR}"
  echo "python_cmd=${PYTHON_CMD[*]}"
  echo "model_path=${MODEL_PATH}"
  echo "prompt=${PROMPT}"
  echo "seed=${SEED}"
  echo "num_timesteps=${NUM_TIMESTEPS}"
  echo "mode=${MODE}"
  echo "think=${THINK}"
  echo
} > "${LOG_PATH}"

cd "${REPO_ROOT}"

run_one() {
  local scale="$1"
  local label="$2"
  local output_path="${OUTPUT_DIR}/cfg_text_${label}.png"

  {
    echo "===== cfg_text_scale=${scale} ====="
    echo "output=${output_path}"
    echo "before_gpu:"
    nvidia-smi || true
    echo "command=${PYTHON_CMD[*]} scripts/run_bagel_minimal.py --task t2i --prompt ${PROMPT} --output ${output_path} --mode ${MODE} --seed ${SEED} --think ${THINK} --num_timesteps ${NUM_TIMESTEPS} --cfg_text_scale ${scale} --model_path ${MODEL_PATH}"
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
    --num_timesteps "${NUM_TIMESTEPS}" \
    --cfg_text_scale "${scale}" \
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

run_one "1.0" "1"
run_one "4.0" "4"
run_one "8.0" "8"

{
  echo "end_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "status=completed"
  echo "outputs:"
  ls -lah "${OUTPUT_DIR}"/cfg_text_*.png
} >> "${LOG_PATH}"
