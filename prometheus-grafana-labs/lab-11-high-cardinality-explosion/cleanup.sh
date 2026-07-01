#!/bin/bash
set -e

echo "Cleaning up Lab 11: High Cardinality Explosion..."

cd "$(dirname "$0")"

docker compose down -v --remove-orphans 2>/dev/null || true
docker rmi $(docker images -q "lab-11*") 2>/dev/null || true

echo "Lab 11 cleaned up successfully."
