#!/bin/bash
#
# numa-check.sh — Diagnose NUMA memory imbalance issues
#

echo "============================================"
echo " NUMA Diagnosis Report"
echo "============================================"
echo ""

# 1. Hardware topology
echo "=== [1/7] NUMA Hardware Topology ==="
numactl --hardware 2>/dev/null || echo "  numactl not available"
echo ""

# 2. Current NUMA statistics
echo "=== [2/7] NUMA Statistics (numastat) ==="
numastat 2>/dev/null || echo "  numastat not available"
echo ""

# 3. Per-process NUMA memory
echo "=== [3/7] Per-Process NUMA Memory (top consumers) ==="
if command -v numastat &>/dev/null; then
    # Get top memory processes
    for pid in $(ps -eo pid --sort=-%mem | head -6 | tail -5); do
        COMM=$(ps -p $pid -o comm= 2>/dev/null)
        if [[ -n "$COMM" ]]; then
            echo "  PID $pid ($COMM):"
            numastat -p $pid 2>/dev/null | grep -E "Total|Node" | head -5
            echo ""
        fi
    done
else
    echo "  numastat not available"
fi
echo ""

# 4. sysctl settings
echo "=== [4/7] NUMA-Related Sysctl Settings ==="
echo "  vm.numa_balancing = $(sysctl -n vm.numa_balancing 2>/dev/null || echo 'N/A')"
echo "  vm.zone_reclaim_mode = $(sysctl -n vm.zone_reclaim_mode 2>/dev/null || echo 'N/A')"
echo "  vm.numa_stat = $(sysctl -n vm.numa_stat 2>/dev/null || echo 'N/A')"
echo "  kernel.numa_balancing = $(sysctl -n kernel.numa_balancing 2>/dev/null || echo 'N/A')"
echo ""

# Assessment
NUMA_BAL=$(sysctl -n vm.numa_balancing 2>/dev/null || echo "0")
ZONE_RECLAIM=$(sysctl -n vm.zone_reclaim_mode 2>/dev/null || echo "0")

echo "  Assessment:"
if [[ "$NUMA_BAL" == "0" ]]; then
    echo "  ⚠️  vm.numa_balancing=0 — Kernel will NOT auto-migrate pages to local node!"
    echo "     Fix: sysctl -w vm.numa_balancing=1"
fi
if [[ "$ZONE_RECLAIM" == "0" ]]; then
    echo "  ⚠️  vm.zone_reclaim_mode=0 — No preference for local node allocation"
    echo "     For NUMA-sensitive workloads, consider zone_reclaim_mode=1"
fi
echo ""

# 5. numad status
echo "=== [5/7] numad (NUMA Daemon) Status ==="
if command -v numad &>/dev/null; then
    echo "  Installed: YES"
    echo "  Running: $(systemctl is-active numad 2>/dev/null || echo 'unknown')"
    if systemctl is-active numad &>/dev/null; then
        echo "  numad is managing NUMA placement"
    else
        echo "  ⚠️  numad is NOT running — no automatic NUMA optimization"
        echo "     Fix: systemctl start numad"
    fi
else
    echo "  Installed: NO"
    echo "  ⚠️  Install with: apt install numad"
fi
echo ""

# 6. Process NUMA policy
echo "=== [6/7] Process Memory Policies ==="
echo "  Checking memory policies of running processes..."
echo ""
for pid in $(ps -eo pid --sort=-%mem | head -6 | tail -5); do
    COMM=$(ps -p $pid -o comm= 2>/dev/null)
    if [[ -n "$COMM" && -f /proc/$pid/numa_maps ]]; then
        echo "  PID $pid ($COMM):"
        # Count pages per NUMA node
        NODE0=$(grep -c "N0=" /proc/$pid/numa_maps 2>/dev/null || echo "0")
        NODE1=$(grep -c "N1=" /proc/$pid/numa_maps 2>/dev/null || echo "0")
        INTERLEAVE=$(grep -c "interleave" /proc/$pid/numa_maps 2>/dev/null || echo "0")
        PREFERRED=$(grep -c "prefer" /proc/$pid/numa_maps 2>/dev/null || echo "0")
        echo "    Mappings with N0 pages: $NODE0"
        echo "    Mappings with N1 pages: $NODE1"
        echo "    Interleave policy entries: $INTERLEAVE"
        echo "    Preferred policy entries: $PREFERRED"
        if [[ $INTERLEAVE -gt 0 ]]; then
            echo "    ⚠️  Using interleave when local preferred would be better"
        fi
        echo ""
    fi
done

# 7. Performance impact estimation
echo "=== [7/7] Remote Access Impact Estimation ==="
echo ""
echo "  Typical NUMA latency numbers:"
echo "    Local node access:  ~80-100ns"
echo "    Remote node access: ~140-200ns (1.5-2x slower)"
echo "    Remote node bandwidth: 50-70% of local"
echo ""
echo "  If 60%+ of memory accesses are remote, expect:"
echo "    - 40-60% application throughput degradation"
echo "    - Higher tail latency (p99)"
echo "    - Increased interconnect (QPI/UPI) saturation"
echo ""
echo "  Verify with perf:"
echo "    perf stat -e node-loads,node-load-misses,node-stores,node-store-misses -p <PID> sleep 5"
echo ""
echo "============================================"
echo " RECOMMENDED FIXES:"
echo "============================================"
echo "  1. Enable NUMA balancing: sysctl -w vm.numa_balancing=1"
echo "  2. Start numad: systemctl enable --now numad"
echo "  3. Pin process to correct NUMA node:"
echo "     numactl --cpunodebind=0 --membind=0 -- <command>"
echo "  4. Use preferred policy for databases:"
echo "     numactl --preferred=0 -- <database_command>"
echo "  5. For zone_reclaim, evaluate workload:"
echo "     sysctl -w vm.zone_reclaim_mode=1 (for NUMA-sensitive apps)"
echo "============================================"
