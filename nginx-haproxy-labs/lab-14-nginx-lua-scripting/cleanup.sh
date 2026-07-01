#!/bin/bash
set -e

echo "[*] Cleaning up Lab 14: Nginx Lua Scripting..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down -v --remove-orphans 2>/dev/null || true

echo "[*] Cleanup complete."
