#!/usr/bin/env bash
set -euo pipefail

sed -n '1,260p' AGENTS.md
sed -n '1,220p' docs/codex_bagel_repro_plan.md
ls -la repro_records
sed -n '1,260p' app.py
sed -n '260,620p' app.py
grep -n "def \|class \|InterleaveInferencer\|cfg_text_scale\|cfg_img_scale\|num_timesteps\|think\|tokenizer\|transforms" app.py
wc -l app.py
grep -n "class InterleaveInferencer\|def __call__\|def interleave_inference\|understanding_output" inferencer.py
sed -n '1,220p' inferencer.py
sed -n '220,420p' inferencer.py
{
  echo "===== wc -l app.py ====="
  wc -l app.py
  echo
  echo "===== app.py key lines ====="
  grep -n "def \|InterleaveInferencer\|cfg_text_scale\|cfg_img_scale\|num_timesteps\|think\|tokenizer\|ImageTransform\|load_checkpoint_and_dispatch\|load_and_quantize_model" app.py
  echo
  echo "===== inferencer key lines ====="
  grep -n "class InterleaveInferencer\|def __call__\|def interleave_inference\|understanding_output\|def gen_image\|def gen_text" inferencer.py
} > repro_records/task03_20260601_145116/logs/app_py_analysis.log 2>&1
ls -la repro_records/task03_20260601_145116
ls -la repro_records/task03_20260601_145116/logs
sed -n '1,260p' repro_records/task03_20260601_145116/summary_app_py.md
sed -n '1,200p' repro_records/task03_20260601_145116/summary_for_ppt.md
tail -80 repro_records/task03_20260601_145116/logs/app_py_analysis.log
