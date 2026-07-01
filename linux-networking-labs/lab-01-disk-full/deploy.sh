#!/bin/bash
# Lab 01: Disk Full - Deleted but open files consuming space
# This safely simulates disk full scenario using /tmp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 01] Deploying: Disk Full (deleted-but-open files)"
echo "======================================================="

# Create large files in /tmp to consume space
echo "[*] Creating large temporary files..."
dd if=/dev/zero of=/tmp/lab01-bigfile1.dat bs=1M count=100 2>/dev/null
dd if=/dev/zero of=/tmp/lab01-bigfile2.dat bs=1M count=100 2>/dev/null
dd if=/dev/zero of=/tmp/lab01-bigfile3.dat bs=1M count=100 2>/dev/null

# Start the simulate script which holds files open then deletes them
echo "[*] Starting background process holding deleted files open..."
bash "$SCRIPT_DIR/simulate.sh" &

echo ""
echo "[✓] Lab 01 deployed!"
echo "    Scenario: The /tmp filesystem is reporting high usage,"
echo "    but you can't find the large files with 'ls' or 'du'."
echo "    Figure out what's consuming the space!"
echo ""
echo "    Start investigating with: df -h /tmp"
