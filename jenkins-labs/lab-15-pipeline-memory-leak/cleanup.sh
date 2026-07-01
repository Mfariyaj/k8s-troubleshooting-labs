#!/bin/bash
set -e

echo "Cleaning up Lab 15: Pipeline Memory Leak..."

cd "$(dirname "$0")"

docker compose down -v 2>/dev/null || true
docker rm -f jenkins-memory-lab 2>/dev/null || true
docker rmi -f jenkins-labs-lab-15-pipeline-memory-leak-jenkins 2>/dev/null || true

echo "Lab 15 cleaned up successfully."
