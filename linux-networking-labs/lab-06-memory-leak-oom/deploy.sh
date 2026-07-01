#!/bin/bash
# Lab 06: Memory Leak / OOM Killer
# Starts a process that leaks memory (safely limited)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 06] Deploying: Memory Leak / OOM"
echo "======================================="

# Use a safe memory limit (256MB by default - adjust if needed)
export LAB06_MAX_MB=256

echo "[*] Starting memory-hungry process (limited to ${LAB06_MAX_MB}MB)..."
python3 "$SCRIPT_DIR/memory-hog.py" > /tmp/.lab06-output.log 2>&1 &
PID=$!
echo "$PID" > /tmp/.lab06-pid

# Wait a moment for some memory to be consumed
sleep 5

echo ""
echo "[✓] Lab 06 deployed!"
echo "    Scenario: A service is consuming abnormal amounts of memory"
echo "    and may eventually trigger the OOM killer."
echo "    Applications are becoming slow due to memory pressure."
echo ""
echo "    Start investigating with:"
echo "      free -m"
echo "      top -o %MEM"
echo "      ps aux --sort=-%mem | head"
echo "      cat /tmp/.lab06-output.log"
echo ""
echo "    To check for OOM events: dmesg | grep -i 'oom\|killed'"
