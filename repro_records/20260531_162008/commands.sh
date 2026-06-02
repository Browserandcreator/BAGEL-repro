#!/usr/bin/env bash
set -u

# 预检查：读取当前路径和项目指令
pwd
sed -n '1,240p' AGENTS.md
sed -n '1,260p' docs/codex_bagel_repro_plan.md

# Task 1: Repository and Weight Check
ls -lah
find . -maxdepth 2 -type f | sort | head -200
ls -lah models || true
ls -lah models/BAGEL-7B-MoT || true
find models/BAGEL-7B-MoT -maxdepth 2 -type f | sort | head -200 || true
du -sh models/BAGEL-7B-MoT || true

# Task 1 补充：关键权重文件完整性检查
for f in models/BAGEL-7B-MoT/llm_config.json models/BAGEL-7B-MoT/vit_config.json models/BAGEL-7B-MoT/ae.safetensors models/BAGEL-7B-MoT/ema.safetensors; do if [ -f "" ]; then ls -lh ""; else echo "MISSING "; fi; done
find models/BAGEL-7B-MoT -type f -name '*.safetensors*' -printf '%p %s bytes\n' | sort | head -300 || true

# Task 1 补充：定位模型目录内大文件和缓存文件
find models/BAGEL-7B-MoT/.cache -maxdepth 5 -type f -printf '%p %s bytes\n' | sort | head -300 || true
du -ah models/BAGEL-7B-MoT | sort -h | tail -50 || true

# Task 1 补充：解析 safetensors index 中的 shard 引用
python - <<'PY'\nimport json, pathlib\nroot = pathlib.Path('models/BAGEL-7B-MoT')\nidx = root / 'model.safetensors.index.json'\nprint('index_exists:', idx.exists())\nif idx.exists():\n    data = json.loads(idx.read_text())\n    files = sorted(set(data.get('weight_map', {}).values()))\n    print('shard_count_in_index:', len(files))\n    missing = [f for f in files if not (root / f).exists()]\n    print('missing_shard_count:', len(missing))\n    for f in files[:20]:\n        p = root / f\n        print(('FOUND' if p.exists() else 'MISSING'), f)\n    if len(files) > 20:\n        print('...')\nPY

# Task 1 收尾：核对记录文件
find repro_records/20260531_162008 -maxdepth 2 -type f | sort
