#!/bin/bash
#
# deploy.sh — Deploy Lab 13: eBPF Program Loading Failures
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Deploying Lab 13: eBPF Program Loading"
echo "============================================"
echo ""
echo "This lab simulates eBPF program loading failures"
echo "commonly encountered with tools like Cilium, Falco,"
echo "Tetragon, and custom BPF-based security agents."
echo ""
echo "Prerequisites:"
echo "  - Linux kernel >= 5.4 (ideally 5.15+)"
echo "  - clang/llvm (for BPF compilation)"
echo "  - bpftool (for loading/inspection)"
echo "  - libbpf-dev (BPF headers)"
echo ""
echo "Install prerequisites:"
echo "  apt install clang llvm libbpf-dev linux-tools-\$(uname -r) bpftool"
echo ""

# Set up intentionally broken environment
echo "[1/3] Setting low RLIMIT_MEMLOCK (simulate unprivileged environment)..."
echo "  Current RLIMIT_MEMLOCK: $(ulimit -l) KB"
echo ""

echo "[2/3] Checking kernel BPF configuration..."
if [[ -f /proc/config.gz ]]; then
    echo "  CONFIG_BPF=$(zcat /proc/config.gz 2>/dev/null | grep CONFIG_BPF= || echo 'unknown')"
    echo "  CONFIG_DEBUG_INFO_BTF=$(zcat /proc/config.gz 2>/dev/null | grep CONFIG_DEBUG_INFO_BTF || echo 'NOT SET')"
elif [[ -f /boot/config-$(uname -r) ]]; then
    echo "  CONFIG_BPF=$(grep CONFIG_BPF= /boot/config-$(uname -r) || echo 'unknown')"
    echo "  CONFIG_DEBUG_INFO_BTF=$(grep CONFIG_DEBUG_INFO_BTF /boot/config-$(uname -r) || echo 'NOT SET')"
fi
echo ""

echo "[3/3] Lab files:"
echo "  broken-bpf.c  — eBPF source with multiple bugs"
echo "  simulate.sh   — Attempts compilation and loading"
echo "  README.md     — Full scenario with verifier output"
echo ""
echo "[✓] Lab deployed. Run ./simulate.sh to attempt BPF loading."
echo ""
echo "============================================"
echo " YOUR TASK: Fix all eBPF program issues"
echo "============================================"
