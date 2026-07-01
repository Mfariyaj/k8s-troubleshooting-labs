#!/bin/bash
#
# cleanup.sh — Clean up Lab 13: eBPF Program Loading
#

echo "============================================"
echo " Cleaning up Lab 13: eBPF Program Loading"
echo "============================================"
echo ""

# Remove loaded BPF programs
echo "[1/3] Removing pinned BPF programs..."
sudo rm -f /sys/fs/bpf/broken_prog 2>/dev/null || true
sudo rm -f /sys/fs/bpf/trace_open 2>/dev/null || true
sudo rm -f /sys/fs/bpf/handle_exec 2>/dev/null || true

# Remove compiled objects
echo "[2/3] Removing compiled BPF objects..."
rm -f /tmp/broken-bpf.o 2>/dev/null || true
rm -f /tmp/fixed-bpf.o 2>/dev/null || true

# Detach any attached BPF programs from kprobes
echo "[3/3] Detaching BPF programs from kprobes..."
# List and remove kprobe events we might have created
if [[ -f /sys/kernel/debug/tracing/kprobe_events ]]; then
    sudo sh -c 'echo > /sys/kernel/debug/tracing/kprobe_events' 2>/dev/null || true
fi

echo ""
echo "[✓] Lab 13 cleaned up successfully."
