#!/bin/bash
set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-13-pid-namespace-exhaustion"

echo "============================================="
echo "  Deploying: $LAB_NAME"
echo "  PID Namespace Exhaustion Scenario"
echo "============================================="
echo ""
echo "[!] WARNING: This lab will generate many zombie processes!"
echo "[!] Monitor with: watch -n1 'ps aux | grep -c Z'"
echo "[!] Current PID max: $(cat /proc/sys/kernel/pid_max 2>/dev/null || echo 'unknown')"
echo ""

cd "$LAB_DIR"

echo "[1/2] Building worker image..."
docker compose build

echo ""
echo "[2/2] Starting workers (3 aggressive forkers + 1 API server)..."
docker compose up -d

echo ""
echo "============================================="
echo "  Lab Deployed!"
echo "============================================="
echo ""
echo "Zombie processes are accumulating NOW."
echo ""
echo "Observe the failure:"
echo "  docker logs -f worker-alpha"
echo "  docker exec worker-alpha ps aux | grep Z | wc -l"
echo "  docker inspect --format '{{.HostConfig.PidMode}}' worker-alpha"
echo "  docker inspect --format '{{.HostConfig.PidsLimit}}' worker-alpha"
echo ""
echo "Within minutes, you may see:"
echo "  - 'docker exec' failing with 'cannot allocate memory'"
echo "  - New containers failing to start"
echo "  - Host becoming unresponsive"
echo ""
echo "Your task: Fix the PID namespace, init system, and worker behavior."
