#!/bin/bash
#
# deploy.sh — Deploy Lab 12: Network Namespace Leak
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Deploying Lab 12: Network Namespace Leak"
echo "============================================"
echo ""
echo "This lab simulates a container runtime bug where orphaned"
echo "network namespaces accumulate, exhausting IPAM allocations."
echo ""
echo "Prerequisites:"
echo "  - Linux VM with root/sudo access"
echo "  - iproute2 (ip command)"
echo "  - bridge-utils (brctl) — optional"
echo ""

echo "[+] Running simulation..."
bash "${SCRIPT_DIR}/simulate.sh"
