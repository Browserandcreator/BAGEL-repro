#!/usr/bin/env bash

export http_proxy=socks5h://127.0.0.1:10808
export https_proxy=socks5h://127.0.0.1:10808
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export all_proxy=$http_proxy
export ALL_PROXY=$http_proxy

export no_proxy="localhost,127.0.0.1,0.0.0.0,::1"
export NO_PROXY="$no_proxy"

exec codex "$@"
