#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if docker info >/dev/null 2>&1; then
  docker compose down
elif id -nG "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx docker && command -v sg >/dev/null 2>&1; then
  sg docker -c "cd \"$ROOT\" && docker compose down"
else
  sudo docker compose down
fi

echo "RaksAppSSO stopped."
