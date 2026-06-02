#!/usr/bin/env bash
set -euo pipefail

pwd
sed -n '1,220p' AGENTS.md
sed -n '1,260p' docs/codex_bagel_repro_plan.md
ls -lah
find . -maxdepth 2 -type f | sort | head -200
ls -lah models || true
ls -lah models/BAGEL-7B-MoT || true
find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
du -sh models/BAGEL-7B-MoT || true
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do if [ -f "" ]; then ls -lh ""; else printf 'MISSING %s\n' ""; fi; done
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader || true
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do if [ -f "$f" ]; then ls -lh "$f"; else printf "MISSING %s\\n" "$f"; fi; done
