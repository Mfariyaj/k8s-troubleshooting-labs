#!/bin/bash
set -e

echo "[*] Cleaning up Lab 15: Dynamic Upstream DNS..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down -v --remove-orphans 2>/dev/null || true

echo "[*] Cleanup complete."
