#!/bin/bash
# Cleanup for Lab 06: Memory Leak / OOM

echo "[Lab 06] Cleaning up..."

# Kill memory hog processes
if [ -f /tmp/.lab06-pid ]; then
    kill "$(cat /tmp/.lab06-pid)" 2>/dev/null
    rm -f /tmp/.lab06-pid
fi

pkill -f "memory-hog.py" 2>/dev/null

# Remove cgroup if created
if [ -d /sys/fs/cgroup/memory/lab06 ]; then
    rmdir /sys/fs/cgroup/memory/lab06 2>/dev/null || true
fi

sleep 1
echo "[✓] Lab 06 cleaned up. Memory released."
