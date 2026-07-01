#!/bin/bash
# Lab 02: Zombie Processes
# Creates zombie processes that accumulate on the system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 02] Deploying: Zombie Processes"
echo "======================================"

echo "[*] Starting zombie creator process..."
bash "$SCRIPT_DIR/zombie-creator.sh" &
disown

# Wait for zombies to appear
sleep 3

ZOMBIE_COUNT=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
echo ""
echo "[✓] Lab 02 deployed!"
echo "    $ZOMBIE_COUNT zombie processes detected."
echo "    Scenario: A monitoring alert fired — zombie process count"
echo "    is increasing. Find the parent and resolve the issue."
echo ""
echo "    Start investigating with: ps aux | grep -w Z"
