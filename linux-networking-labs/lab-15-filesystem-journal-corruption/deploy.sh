#!/bin/bash
#
# deploy.sh — Deploy Lab 15: Filesystem Journal Corruption
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Deploying Lab 15: Filesystem Journal Corruption"
echo "============================================"
echo ""
echo "This lab simulates ext4 journal corruption causing a"
echo "filesystem to remount read-only. You must diagnose and"
echo "repair without data loss."
echo ""
echo "Prerequisites:"
echo "  - Linux VM with root/sudo access"
echo "  - e2fsprogs (e2fsck, debugfs, dumpe2fs)"
echo "  - losetup capability"
echo ""
echo "This is safe — uses a loopback file, not real partitions."
echo ""

echo "[+] Running simulation..."
bash "${SCRIPT_DIR}/simulate.sh"
