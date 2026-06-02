#!/usr/bin/env bash
set -euo pipefail

sed -n '1,260p' AGENTS.md
sed -n '1,520p' docs/codex_bagel_repro_plan.md
wc -l inferencer.py
grep -n "class InterleaveInferencer\|def init_gen_context\|def update_context_text\|def update_context_image\|def gen_text\|def gen_image\|def interleave_inference\|understanding_output\|think" inferencer.py
sed -n '1,260p' inferencer.py
sed -n '261,560p' inferencer.py
nvidia-smi

# Additional command used to save the combined raw inspection log:
{
  echo '===== AGENTS.md ====='
  sed -n '1,260p' AGENTS.md
  echo
  echo '===== docs/codex_bagel_repro_plan.md ====='
  sed -n '1,520p' docs/codex_bagel_repro_plan.md
  echo
  echo '===== wc -l inferencer.py ====='
  wc -l inferencer.py
  echo
  echo '===== inferencer.py key lines ====='
  grep -n "class InterleaveInferencer\|def init_gen_context\|def update_context_text\|def update_context_image\|def gen_text\|def gen_image\|def interleave_inference\|understanding_output\|think" inferencer.py
  echo
  echo '===== inferencer.py 1-260 ====='
  sed -n '1,260p' inferencer.py
  echo
  echo '===== inferencer.py 261-560 ====='
  sed -n '261,560p' inferencer.py
  echo
  echo '===== nvidia-smi ====='
  nvidia-smi
} > repro_records/task04_20260601_152117/logs/inferencer_py_analysis.log 2>&1
ls -la repro_records/task04_20260601_152117
ls -la repro_records/task04_20260601_152117/logs
sed -n '1,260p' repro_records/task04_20260601_152117/summary_inferencer_py.md
sed -n '1,120p' repro_records/task04_20260601_152117/summary_for_ppt.md
sed -n '1,120p' repro_records/task04_20260601_152117/bugfix_log.md
