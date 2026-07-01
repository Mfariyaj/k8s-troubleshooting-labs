#!/bin/bash
set -e

echo "Cleaning up Lab 11: JCasC YAML Merge Failures..."

cd "$(dirname "$0")"

docker compose down -v 2>/dev/null || true
docker rm -f jenkins-casc-lab 2>/dev/null || true

echo "Lab 11 cleaned up successfully."
