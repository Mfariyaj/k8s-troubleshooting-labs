#!/bin/bash
set -e

echo "Cleaning up Lab 13: Pipeline Replay Divergence..."

cd "$(dirname "$0")"

docker rm -f jenkins-replay-lab 2>/dev/null || true

echo "Lab 13 cleaned up successfully."
