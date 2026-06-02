#!/usr/bin/env bash
set -euo pipefail

# Task 1: Repository and Weight Check
cd /root/autodl-tmp/BAGEL

# Initial default sandbox attempts failed with:
# bwrap: No permissions to create a new namespace, likely because the kernel does not allow non-privileged user namespaces.
# The following commands were then run with external execution permission.

pwd
sed -n '1,240p' AGENTS.md
sed -n '1,260p' docs/codex_bagel_repro_plan.md
ls -lah
find . -maxdepth 2 -type f | sort | head -200
ls -lah models || true
ls -lah models/BAGEL-7B-MoT || true
find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
du -sh models/BAGEL-7B-MoT || true
nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader || true
find models/BAGEL-7B-MoT -maxdepth 3 -type f -name "*.safetensors" -printf "%p	%s bytes\n" | sort
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do test -f "$f" && echo "OK $f" || echo "MISSING $f"; done
du -ah models/BAGEL-7B-MoT | sort -h | tail -40
find repro_records/20260531_162431 -maxdepth 2 -type f | sort
