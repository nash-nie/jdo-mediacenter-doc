#!/usr/bin/env bash
# 启动 MkDocs 本地预览
# 使用方式：./scripts/serve-docs.sh
# 默认端口 8000，也可以传入参数指定：./scripts/serve-docs.sh 8080

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-8000}"

cd "$PROJECT_ROOT"

if ! command -v mkdocs >/dev/null 2>&1; then
  echo "[serve-docs] mkdocs 未安装，正在安装文档依赖..."
  pip3 install --user -r requirements-docs.txt
fi

echo "[serve-docs] 启动本地预览：http://127.0.0.1:${PORT}/"
mkdocs serve -a "127.0.0.1:${PORT}"
