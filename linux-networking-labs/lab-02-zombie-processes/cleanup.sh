#!/bin/bash
# Cleanup for Lab 02: Zombie Processes

echo "[Lab 02] Cleaning up..."

# Remove the marker file
rm -f /tmp/.lab02-zombie-running

# Kill the parent process
if [ -f /tmp/.lab02-parent-pid ]; then
    kill "$(cat /tmp/.lab02-parent-pid)" 2>/dev/null
    rm -f /tmp/.lab02-parent-pid
fi

# Kill any remaining zombie-creator processes
pkill -f "zombie-creator.sh" 2>/dev/null

sleep 1

ZOMBIE_COUNT=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
echo "[✓] Lab 02 cleaned up. Remaining zombies: $ZOMBIE_COUNT"
