#!/bin/bash
set -e

echo "[*] Cleaning up Lab 13: HAProxy Stick-Table..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down -v --remove-orphans 2>/dev/null || true

echo "[*] Cleanup complete."
