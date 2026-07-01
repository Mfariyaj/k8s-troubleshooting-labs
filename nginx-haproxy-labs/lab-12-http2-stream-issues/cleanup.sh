#!/bin/bash
set -e

echo "[*] Cleaning up Lab 12: HTTP/2 Stream Issues..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down -v --remove-orphans 2>/dev/null || true

echo "[*] Removing SSL certificates..."
rm -rf ssl/

echo "[*] Cleanup complete."
