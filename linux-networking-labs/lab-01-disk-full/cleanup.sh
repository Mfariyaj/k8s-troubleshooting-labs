#!/bin/bash
# Cleanup for Lab 01: Disk Full

echo "[Lab 01] Cleaning up..."

# Remove the marker file to stop the simulate.sh loop
rm -f /tmp/.lab01-simulate-running

# Kill any tail process from the lab
if [ -f /tmp/.lab01-tail-pid ]; then
    kill "$(cat /tmp/.lab01-tail-pid)" 2>/dev/null
    rm -f /tmp/.lab01-tail-pid
fi

# Kill simulate.sh processes
pkill -f "lab01-simulate-running" 2>/dev/null
pkill -f "simulate.sh" 2>/dev/null

# Remove all lab files
rm -f /tmp/lab01-*.dat
rm -f /tmp/.lab01-*

# Wait a moment for processes to die
sleep 1

echo "[✓] Lab 01 cleaned up. Space freed."
