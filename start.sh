#!/bin/bash
set -euo pipefail

if [[ -z "${JUPYTER_TOKEN:-}" ]]; then
  echo "ERROR: Set JUPYTER_TOKEN in your hosting environment."
  exit 1
fi

PORT="${PORT:-10000}"
echo "============================================================"
echo "  EVILSAAD JUPYTER - Starting secure notebook workspace"
echo "  Port: ${PORT}"
echo "============================================================"
exec start-notebook.py \
  --ServerApp.ip=0.0.0.0 \
  --ServerApp.port="${PORT}" \
  --ServerApp.root_dir=/home/jovyan/work \
  --ServerApp.allow_remote_access=True \
  --ServerApp.open_browser=False
