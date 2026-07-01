#!/bin/bash
# Cleanup for Lab 08: Swap Thrashing

echo "[Lab 08] Cleaning up..."

# Kill the memory processes
if [ -f /tmp/.lab08-pids ]; then
    for pid in $(cat /tmp/.lab08-pids); do
        kill "$pid" 2>/dev/null
    done
    rm -f /tmp/.lab08-pids
fi

# Restore original swappiness
if [ -f /tmp/.lab08-orig-swappiness ]; then
    ORIG=$(cat /tmp/.lab08-orig-swappiness)
    echo "$ORIG" > /proc/sys/vm/swappiness 2>/dev/null || true
    rm -f /tmp/.lab08-orig-swappiness
fi

sleep 2
echo "[✓] Lab 08 cleaned up. Memory released, swappiness restored."
echo "    Current free memory: $(free -m | awk '/Mem:/ {print $4}')MB"
