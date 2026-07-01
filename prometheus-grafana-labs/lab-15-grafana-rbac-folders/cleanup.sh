#!/bin/bash
set -e

echo "Cleaning up Lab 15: Grafana RBAC Folders..."

cd "$(dirname "$0")"

docker compose down -v --remove-orphans 2>/dev/null || true

echo "Lab 15 cleaned up successfully."
