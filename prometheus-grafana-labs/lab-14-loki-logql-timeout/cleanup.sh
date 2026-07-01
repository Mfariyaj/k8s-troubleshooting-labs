#!/bin/bash
set -e

echo "Cleaning up Lab 14: Loki LogQL Timeout..."

cd "$(dirname "$0")"

docker compose down -v --remove-orphans 2>/dev/null || true

echo "Lab 14 cleaned up successfully."
