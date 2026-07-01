#!/bin/bash
set -e

echo "[*] Cleaning up Lab 11: mTLS Client Certificate..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down -v --remove-orphans 2>/dev/null || true

echo "[*] Removing generated certificates..."
rm -rf certs/

echo "[*] Cleanup complete."
