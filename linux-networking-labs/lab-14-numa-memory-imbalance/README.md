# Lab 14: NUMA Memory Imbalance — Cross-Node Performance Degradation

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

A production PostgreSQL database server (handling 50K transactions/sec) has mysteriously degraded by **60%** in throughput over the past 2 weeks. No code changes, no schema changes, no traffic increase. The DBA team is baffled.

After initial investigation, you notice the server is a **dual-socket system** (2 NUMA nodes). A "performance optimization" change was applied 2 weeks ago by a well-meaning sysadmin who disabled NUMA balancing "to reduce overhead" and set memory interleave policy "for fairness."

The result: PostgreSQL's shared buffers (32GB) are now spread across both NUMA nodes, but the process runs predominantly on Node 0 CPUs. Every other memory access crosses the QPI/UPI interconnect at 2x the latency.

## Environment

- **OS**: RHEL 8.8 (Kernel 4.18.0-477)
- **Hardware**: 2x Intel Xeon Gold 6348, 256GB RAM (128GB per node)
- **NUMA Topology**: 2 nodes, 28 cores per node, 56 cores total
- **Application**: PostgreSQL 15, shared_buffers=32GB
- **Workload**: OLTP, 50K TPS baseline (now: 20K TPS)

## Symptoms Observed

### Performance comparison:
```
Before (2 weeks ago):
  TPS: 52,341
  Avg latency: 1.2ms
  p99 latency: 4.8ms
  CPU utilization: 45%

After (now):
  TPS: 21,892  (↓58%)
  Avg latency: 3.1ms (↑158%)
  p99 latency: 18.4ms (↑283%)
  CPU utilization: 78% (↑73%)
```

### numactl --hardware:
```
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
node 0 size: 131072 MB
node 0 free: 12341 MB
node 1 cpus: 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55
node 1 size: 131072 MB
node 1 free: 98234 MB
distances:
node   0   1
  0:  10  21
  1:  21  10
```

### numastat -p postgres (PID 4521):
```
Per-node process memory usage (in MBs) for PID 4521 (postgres)
                           Node 0          Node 1           Total
                  --------------- --------------- ---------------
Huge                         0.00            0.00            0.00
Heap                       124.56          891.23         1015.79
Stack                        0.12            0.00            0.12
Private                   8234.56        24891.34        33125.90
----------------  --------------- --------------- ---------------
Total                     8359.24        25782.57        34141.81
```
*Note: Process runs on Node 0 CPUs but 75% of memory is on Node 1!*

### perf stat for PostgreSQL:
```
$ sudo perf stat -e node-loads,node-load-misses,node-stores,node-store-misses -p 4521 -- sleep 10

 Performance counter stats for process id '4521':

     2,341,892,345      node-loads
     1,498,234,123      node-load-misses     #  63.97% of all node loads
       891,234,567      node-stores
       534,123,456      node-store-misses    #  59.93% of all node stores

      10.001234567 seconds time elapsed
```
*64% of memory loads are remote! Normal should be <10%.*

### /proc/4521/numa_maps (excerpt):
```
7f1a2c000000 interleave:0-1 anon=8388608 dirty=8388608 active=8388608 N0=4194304 N1=4194304
7f1a4c000000 interleave:0-1 anon=524288 dirty=524288 active=524288 N0=262144 N1=262144
```
*Memory policy: interleave — distributes pages evenly across all nodes*

### sysctl settings:
```
$ sysctl vm.numa_balancing
vm.numa_balancing = 0
$ sysctl vm.zone_reclaim_mode
vm.zone_reclaim_mode = 0
$ systemctl is-active numad
inactive
```

### Change log from 2 weeks ago:
```
commit a3b4c5d: "Disable NUMA balancing to reduce kernel overhead"
  sysctl -w vm.numa_balancing=0
  systemctl stop numad
  
commit f6e7d8c: "Set memory interleave for fair NUMA distribution"
  numactl --interleave=all -- /usr/pgsql-15/bin/postgres ...
```

### top output showing CPU:
```
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM   COMMAND
 4521 postgres  20   0   35.2g  33.4g   2.1g S 312.3  12.8   postgres
 4522 postgres  20   0   35.2g  128m    45m  S  48.2   0.0   postgres: wal writer
 4523 postgres  20   0   35.2g   98m    32m  S  23.1   0.0   postgres: bgwriter
```
*PostgreSQL using CPUs 0-5 (all Node 0), but 75% memory on Node 1.*

## Your Task

1. Identify the NUMA misconfiguration causing performance degradation
2. Understand why `interleave` policy is wrong for a database workload
3. Fix sysctl settings to enable proper NUMA-aware memory management
4. Pin PostgreSQL to proper NUMA node with correct memory policy
5. Enable `numad` for automatic NUMA optimization
6. Verify performance recovery with perf counters

## Useful Commands

```bash
# NUMA topology
numactl --hardware
lscpu | grep -i numa
lstopo (if hwloc installed)

# Per-process NUMA stats
numastat -p <PID>
cat /proc/<PID>/numa_maps | head -20

# Memory policy
cat /proc/<PID>/numa_maps | grep -c "interleave"
cat /proc/<PID>/numa_maps | grep -c "prefer"

# perf NUMA counters
perf stat -e node-loads,node-load-misses -p <PID> sleep 5

# CPU-to-NUMA mapping
cat /sys/devices/system/node/node0/cpulist
cat /sys/devices/system/node/node1/cpulist

# Fix: Run postgres with correct NUMA policy
numactl --cpunodebind=0 --preferred=0 -- postgres -D /var/lib/pgsql/data

# Fix: Enable NUMA balancing
sysctl -w vm.numa_balancing=1

# Fix: Enable zone reclaim for local preference
sysctl -w vm.zone_reclaim_mode=1

# Fix: Start numad
systemctl enable --now numad

# Monitor cross-node traffic
perf stat -e offcore_response.all_data_rd.l3_miss.any_snoop -p <PID> sleep 10

# Memory migration
migratepages <PID> 1 0  # Move pages from node 1 to node 0
```

## Hints

<details>
<summary>Hint 1</summary>
Check <code>/proc/&lt;PID&gt;/numa_maps</code> — you'll see the memory policy is <code>interleave:0-1</code>. This distributes pages round-robin across NUMA nodes. For a database that runs on Node 0 CPUs, this means ~50% of every memory access goes to the remote node at 2x latency. The correct policy is <code>preferred=0</code> or <code>membind=0</code>.
</details>

<details>
<summary>Hint 2</summary>
<code>vm.numa_balancing=0</code> disables the kernel's automatic NUMA page migration. Normally, when the kernel detects a process repeatedly accessing remote memory, it migrates those pages closer. With this disabled, misplaced pages stay remote forever. Enable with <code>sysctl -w vm.numa_balancing=1</code>.
</details>

<details>
<summary>Hint 3</summary>
The fix requires multiple steps: (1) Stop PostgreSQL, (2) restart with <code>numactl --cpunodebind=0 --preferred=0</code>, (3) enable <code>vm.numa_balancing=1</code>, (4) start <code>numad</code> for ongoing optimization. You can also migrate existing pages with <code>migratepages &lt;PID&gt; 1 0</code> without restart if downtime is unacceptable.
</details>

## Root Causes

This lab demonstrates **NUMA-unaware configuration** causing severe performance degradation:

1. **`vm.numa_balancing=0`** — Kernel cannot auto-migrate pages to the local NUMA node. Memory stays wherever it was initially allocated, even if the process always accesses it from a different node.

2. **Interleave memory policy** — The `--interleave=all` flag distributes pages evenly across nodes. This is optimal for processes that use ALL CPUs across all nodes (like kernel hash tables), but TERRIBLE for a database pinned to one node's CPUs.

3. **`numad` not running** — The NUMA daemon would have detected the imbalance and recommended (or auto-applied) better placement.

4. **`vm.zone_reclaim_mode=0`** — When Node 0 is under memory pressure, the kernel allocates from Node 1 instead of reclaiming local memory. For NUMA-sensitive workloads, local reclaim is preferred.

5. **No CPU pinning enforcement** — PostgreSQL migrates between CPUs but its memory stays. Without explicit `cpunodebind`, the scheduler might run postgres on Node 0 while its memory is on Node 1.
