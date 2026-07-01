#!/bin/bash
# Lab 10: Application that should run as a systemd service
# This is the actual app - it works fine when run directly

echo "[lab10-app] Application starting..."
echo "[lab10-app] PID: $$"
echo "[lab10-app] Working directory: $(pwd)"
echo "[lab10-app] Listening on port 9090..."

# Simple loop to simulate a running service
COUNT=0
while true; do
    COUNT=$((COUNT + 1))
    if [ $((COUNT % 60)) -eq 0 ]; then
        echo "[lab10-app] Heartbeat: processed $COUNT cycles"
    fi
    sleep 1
done
