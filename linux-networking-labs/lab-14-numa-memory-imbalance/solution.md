# Solution: Lab 14 - NUMA Memory Imbalance

## Problem

Application performance is degraded on a multi-socket NUMA system. Memory is heavily
allocated on remote NUMA nodes, causing high latency memory accesses.

## Diagnosis

```bash
# Check NUMA topology
numactl --hardware
lscpu | grep NUMA

# Check per-node memory usage
numastat

# Check NUMA misses (remote accesses)
numastat -p <PID>

# Check if numa_balancing is enabled
cat /proc/sys/kernel/numa_balancing

# Check memory placement policy
cat /proc/<PID>/numa_maps | grep -c "N0\|N1"
```

## Root Cause

Memory is being allocated on remote NUMA nodes, causing cross-socket memory access.
NUMA auto-balancing is disabled, and the application hasn't been pinned to local
memory. This causes 2-3x latency penalties on remote memory accesses.

## Fix

### Step 1: Enable NUMA auto-balancing

```bash
# Enable kernel NUMA balancing
sudo sysctl -w kernel.numa_balancing=1

# Make persistent
echo "kernel.numa_balancing=1" | sudo tee -a /etc/sysctl.d/99-numa.conf
```

### Step 2: Use numactl to pin process to local memory

```bash
# Run application with local memory allocation policy
numactl --localalloc /path/to/application

# Or bind to a specific node (both CPUs and memory)
numactl --cpunodebind=0 --membind=0 /path/to/application

# For running processes, use migratepages
migratepages <PID> 1 0
```

### Step 3: Start numad for automatic optimization

```bash
# Install and start numad (automatic NUMA placement daemon)
sudo apt install numad  # or yum install numad
sudo systemctl enable numad
sudo systemctl start numad
```

## Verification

```bash
# Check numa_balancing is enabled
cat /proc/sys/kernel/numa_balancing

# Check memory is now locally allocated
numastat -p <PID>

# Verify numad is running
systemctl status numad

# Performance test — latency should decrease
numactl --hardware
```

## Prevention

- Enable `kernel.numa_balancing=1` on all NUMA systems
- Use `numactl --localalloc` in service startup scripts
- Run numad on multi-socket systems for automatic placement
- Design applications to be NUMA-aware (thread-per-node pattern)
- Monitor NUMA statistics via node_exporter
