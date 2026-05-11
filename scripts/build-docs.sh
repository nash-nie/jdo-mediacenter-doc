#!/usr/bin/env bash
# 构建 MkDocs 静态站点到 site/ 目录
# 使用方式：./scripts/build-docs.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v mkdocs >/dev/null 2>&1; then
  echo "[build-docs] mkdocs 未安装，正在安装文档依赖..."
  pip3 install --user -r requirements-docs.txt
fi

echo "[build-docs] 构建静态站点..."
mkdocs build --strict --clean

echo "[build-docs] 完成，产物位于 ./site/"
