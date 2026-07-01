#!/bin/bash
#
# simulate.sh — Simulates NUMA memory imbalance causing performance degradation
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Lab 14: NUMA Memory Imbalance Simulation"
echo "============================================"
echo ""

# Check if system has NUMA
if ! command -v numactl &>/dev/null; then
    echo "ERROR: numactl not installed."
    echo "Install with: apt install numactl"
    exit 1
fi

NUMA_NODES=$(numactl --hardware 2>/dev/null | grep "available:" | awk '{print $2}')
echo "NUMA nodes detected: ${NUMA_NODES:-unknown}"
echo ""

if [[ "${NUMA_NODES:-0}" -lt 2 ]]; then
    echo "WARNING: This system has fewer than 2 NUMA nodes."
    echo "The simulation will run but the actual performance impact"
    echo "won't be observable. Ideal lab environment: 2+ NUMA node server."
    echo ""
    echo "Continuing with simulated scenario output..."
    echo ""
fi

echo "[1/5] Applying broken NUMA sysctl settings..."
# Disable NUMA balancing
sudo sysctl -w vm.numa_balancing=0 2>/dev/null || true
# Disable zone reclaim (prevents local node reclaim)
sudo sysctl -w vm.zone_reclaim_mode=0 2>/dev/null || true
echo "  vm.numa_balancing = 0 (auto-migration disabled)"
echo "  vm.zone_reclaim_mode = 0 (local reclaim disabled)"
echo ""

echo "[2/5] Stopping numad (if running)..."
sudo systemctl stop numad 2>/dev/null || true
sudo systemctl disable numad 2>/dev/null || true
echo "  numad: stopped/disabled"
echo ""

echo "[3/5] Allocating memory on WRONG NUMA node..."
echo "  This simulates a database process running on Node 0"
echo "  but having its memory allocated on Node 1 (remote)."
echo ""

# Allocate memory with intentionally wrong NUMA policy
# If we have 2+ nodes, allocate on the "wrong" node
if [[ "${NUMA_NODES:-0}" -ge 2 ]]; then
    # Start a process pinned to CPU on node 0 but allocate memory on node 1
    echo "  Starting memory-intensive process pinned to Node 0 CPUs..."
    echo "  with memory policy: interleave (should be 'preferred=node0')"
    echo ""
    
    # Get CPUs for node 0
    NODE0_CPUS=$(numactl --hardware 2>/dev/null | grep "node 0 cpus:" | cut -d: -f2 | xargs)
    FIRST_CPU=$(echo "$NODE0_CPUS" | awk '{print $1}')
    
    # Allocate with wrong policy: membind to remote node
    numactl --cpunodebind=0 --interleave=all -- dd if=/dev/zero of=/dev/null bs=1M count=512 &
    BG_PID=$!
    
    echo "  Process PID: $BG_PID"
    echo "  CPU affinity: Node 0 (correct)"
    echo "  Memory policy: interleave=all (WRONG — should be preferred=0)"
    echo ""
    
    # Also start one with membind to wrong node
    numactl --cpunodebind=0 --membind=1 -- stress-ng --vm 1 --vm-bytes 256M --timeout 60s &>/dev/null &
    BG_PID2=$!
    echo "  Process PID: $BG_PID2"
    echo "  CPU affinity: Node 0"
    echo "  Memory policy: membind=1 (WRONG — memory on remote node)"
    echo ""
    
    # Give processes time to allocate
    sleep 3
    
    echo "  PIDs running: $BG_PID $BG_PID2"
    echo "  Kill with: kill $BG_PID $BG_PID2"
else
    echo "  (Skipped — single NUMA node system)"
    echo "  On a multi-NUMA system, this would start processes with remote memory."
fi
echo ""

echo "[4/5] Showing NUMA status..."
echo ""
numactl --hardware 2>/dev/null || echo "  (numactl not available)"
echo ""
numastat 2>/dev/null | head -20 || echo "  (numastat not available)"
echo ""

echo "[5/5] Displaying broken state summary..."
echo ""
echo "============================================"
echo " BROKEN STATE:"
echo "============================================"
echo ""
echo "Current problematic settings:"
echo "  vm.numa_balancing = $(sysctl -n vm.numa_balancing 2>/dev/null || echo 'N/A')"
echo "  vm.zone_reclaim_mode = $(sysctl -n vm.zone_reclaim_mode 2>/dev/null || echo 'N/A')"
echo "  numad running: $(systemctl is-active numad 2>/dev/null || echo 'inactive')"
echo ""
echo "Evidence of remote memory access:"
echo "  - Process running on Node 0 CPUs"
echo "  - Memory allocated on Node 1 (or interleaved across all nodes)"
echo "  - Every memory access crosses the interconnect (QPI/UPI)"
echo "  - Expected latency penalty: 40-100ns per access (1.5-2x slower)"
echo ""
echo "============================================"
echo " YOUR TASK: Fix the NUMA configuration"
echo "  Run: ./numa-check.sh to see full diagnosis"
echo "============================================"
