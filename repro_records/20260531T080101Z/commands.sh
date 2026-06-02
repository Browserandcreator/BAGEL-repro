#!/usr/bin/env bash
set -euo pipefail

# Task 0: Environment Check

# bootstrap
ts=$(date -u +%Y%m%dT%H%M%SZ); dir=/root/repro_records/$ts; mkdir -p "$dir/logs"; printf "%s\n" "$dir"; printf "#!/usr/bin/env bash\nset -euo pipefail\n\n# Task 0: Environment Check\n" > "$dir/commands.sh"; chmod +x "$dir/commands.sh"; printf "Task 0 environment check log\nRecord dir: %s\n\n" "$dir" > "$dir/logs/env_check.log"

# read AGENTS.md
sed -n '1,220p' /root/AGENTS.md

# read codex_bagel_repro_plan
sed -n '1,260p' /root/docs/codex_bagel_repro_plan.md

# inspect logged instructions
sed -n '1,320p' /root/repro_records/20260531T080101Z/logs/env_check.log

# locate requested files
find /root -path /root/miniconda3 -prune -o -path /root/.cache -prune -o -name AGENTS.md -o -path '*/docs/codex_bagel_repro_plan.md' -print

# list project root
ls -la /root/autodl-tmp/BAGEL

# read project AGENTS.md
sed -n '1,220p' /root/autodl-tmp/BAGEL/AGENTS.md

# read repro plan
sed -n '1,280p' /root/autodl-tmp/BAGEL/docs/codex_bagel_repro_plan.md

# move records into repository repro_records
SRC=/root/repro_records/20260531T080101Z
DST=/root/autodl-tmp/BAGEL/repro_records/20260531T080101Z
mkdir -p "$DST/logs"
cp "$SRC/commands.sh" "$DST/commands.sh"
cp "$SRC/logs/env_check.log" "$DST/logs/env_check.log"

# task0 pwd
pwd

# task0 git rev
git rev-parse HEAD

# task0 git status
git status --short

# task0 python version
/root/miniconda3/bin/conda run -n bagel python -V

# task0 python path
/root/miniconda3/bin/conda run -n bagel which python

# task0 selected pip packages
/root/miniconda3/bin/conda run -n bagel pip list | grep -E 'torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors|huggingface'

# task0 nvidia-smi
nvidia-smi

# task0 disk free
df -h

# task0 repo size
du -sh .

# task0 conda env list
/root/miniconda3/bin/conda env list

# task0 selected conda packages
/root/miniconda3/bin/conda list -n bagel | grep -E 'torch|flash|accelerate|transformers|gradio|bitsandbytes|safetensors'

# inspect task0 log
sed -n '1,520p' /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z/logs/env_check.log

# inspect task0 log continued
sed -n '521,900p' /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z/logs/env_check.log

# task0 torch cuda status
/root/miniconda3/bin/conda run -n bagel python -c 'import torch; print("torch", torch.__version__); print("torch_cuda", torch.version.cuda); print("cuda_available", torch.cuda.is_available()); print("device_count", torch.cuda.device_count()); [print(f"device_{i}", torch.cuda.get_device_name(i), torch.cuda.get_device_properties(i).total_memory) for i in range(torch.cuda.device_count())]'

# verify task0 output files
ls -lah /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z/logs

# report localization prep line count
wc -l /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z/00_env_check.md

# verify localized task0 report
sed -n '1,140p' /root/autodl-tmp/BAGEL/repro_records/20260531T080101Z/00_env_check.md
