#!/bin/bash
set -e

echo "Cleaning up Lab 13: Thanos Sidecar Issues..."

cd "$(dirname "$0")"

docker compose down -v --remove-orphans 2>/dev/null || true

echo "Lab 13 cleaned up successfully."
