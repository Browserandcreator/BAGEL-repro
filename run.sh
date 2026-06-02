#!/usr/bin/env bash

cd /root/autodl-tmp/BAGEL

source /root/miniconda3/etc/profile.d/conda.sh
conda activate bagel

export CUDA_VISIBLE_DEVICES=0,1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

# 如果你的本地代理还开着，就保留这几行；如果不需要联网，也可以删掉
# export http_proxy=socks5h://127.0.0.1:10808
# export https_proxy=socks5h://127.0.0.1:10808
# export HTTP_PROXY=$http_proxy
# export HTTPS_PROXY=$https_proxy
# export all_proxy=$http_proxy
# export ALL_PROXY=$http_proxy

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset all_proxy
unset ALL_PROXY

python app.py \
  --mode 2 \
  --zh \
  --server_name 0.0.0.0 \
  --server_port 7860
