#!/bin/bash
set -e

echo "Cleaning up Lab 12: WAL Corruption..."

cd "$(dirname "$0")"

docker compose down -v --remove-orphans 2>/dev/null || true

echo "Lab 12 cleaned up successfully."
