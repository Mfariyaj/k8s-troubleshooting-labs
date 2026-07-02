## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (simulates the broken system state)
2. Investigate using standard Linux tools: `df`, `ps`, `ss`, `dmesg`, `journalctl`
3. Identify the root cause from system output
4. Apply the fix (the README hints at what's wrong)
5. Verify the system is healthy
6. Cleanup: `./cleanup.sh`. Check `solution.md` if stuck

---

# Lab 11: Kernel Soft Lockup — Network Packet Processing Storm

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Production web server handling 200K+ requests/second has become unresponsive. The kernel is reporting **soft lockup** messages, all CPU cores show extremely high `%si` (softirq) time, and `ksoftirqd` threads are pegged at 100%. The system isn't crashed — it's alive but completely starved of CPU for userspace processes.

The network team reports the server is still receiving traffic, but application latency has gone from 2ms to 15+ seconds. The NOC is escalating.

## Environment

- **OS**: Ubuntu 22.04 LTS (Kernel 5.15.0-generic)
- **Hardware**: 8-core Xeon, 64GB RAM, Intel X710 10GbE NIC (2 ports)
- **Role**: High-traffic reverse proxy / load balancer
- **Traffic**: Burst from 200K to 2M+ small UDP packets/sec (possible DDoS or misbehaving upstream)

## Symptoms Observed

### dmesg output:
```
[438291.123456] watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [ksoftirqd/0:7]
[438291.123457] Modules linked in: x710_driver ip_tables nf_conntrack ...
[438291.123460] CPU: 0 PID: 7 Comm: ksoftirqd/0 Not tainted 5.15.0-76-generic #83-Ubuntu
[438291.123462] RIP: 0010:net_rx_action+0x142/0x320
[438291.123465] Call Trace:
[438291.123466]  __do_softirq+0xd1/0x2c8
[438291.123467]  run_ksoftirqd+0x22/0x50
[438291.123468]  smpboot_thread_fn+0xc5/0x1f0
[438291.123469]  kthread+0x127/0x150
[438314.789012] watchdog: BUG: soft lockup - CPU#0 stuck for 46s! [ksoftirqd/0:7]
[438337.456789] watchdog: BUG: soft lockup - CPU#0 stuck for 69s! [ksoftirqd/0:7]
[438337.456790] NAPI poll: budget exhausted on eth0-rx-0 after 10 packets (budget=10)
```

### top output:
```
top - 14:23:17 up 45 days, 3:12,  2 users,  load average: 87.32, 72.15, 48.90

Tasks: 312 total,   1 running, 311 sleeping,   0 stopped,   0 zombie
%Cpu0  :  0.3 us,  0.0 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi, 99.7 si,  0.0 st
%Cpu1  :  2.1 us,  0.5 sy,  0.0 ni, 97.2 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu2  :  1.8 us,  0.3 sy,  0.0 ni, 97.7 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu3  :  2.0 us,  0.4 sy,  0.0 ni, 97.4 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu4  :  1.5 us,  0.2 sy,  0.0 ni, 98.1 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu5  :  1.9 us,  0.3 sy,  0.0 ni, 97.6 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu6  :  2.2 us,  0.4 sy,  0.0 ni, 97.2 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
%Cpu7  :  1.7 us,  0.3 sy,  0.0 ni, 97.8 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
    7 root      20   0       0      0      0 R  99.7   0.0  12847:23 ksoftirqd/0
 1823 root      20   0  4.2g  1.2g   45m S   4.2   1.9   2341:12 nginx
```

### /proc/interrupts (abbreviated):
```
           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7
 45:  982741823          0          0          0          0          0          0          0   PCI-MSI 524288-edge      eth0-rx-0
 46:  891234567          0          0          0          0          0          0          0   PCI-MSI 524289-edge      eth0-rx-1
 47:  743218901          0          0          0          0          0          0          0   PCI-MSI 524290-edge      eth0-rx-2
 48:  654321098          0          0          0          0          0          0          0   PCI-MSI 524291-edge      eth0-rx-3
 49:       1234    8723145          0          0          0          0          0          0   PCI-MSI 524292-edge      eth0-tx-0
```

### /proc/net/softnet_stat (CPU0):
```
0x012fba3c 0x003d2f1a 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000
```
*(Column 2: 0x003d2f1a = 4,009,754 time_squeeze events — budget exhausted before queue empty)*

### ethtool -g eth0:
```
Ring parameters for eth0:
Pre-set maximums:
RX:             4096
RX Mini:        n/a
RX Jumbo:       n/a
TX:             4096
Current hardware settings:
RX:             64
RX Mini:        n/a
RX Jumbo:       n/a
TX:             64
```

### ss -s:
```
Total: 89234
TCP:   45123 (estab 12034, closed 28901, orphaned 234, timewait 28667)
UDP:   2341901 (recv-q overflows: 1893421)
```

## Your Task

1. Identify why all packet processing is stuck on CPU0
2. Understand why the NAPI budget is exhausted so quickly
3. Fix the sysctl tunables to handle high packet rates
4. Distribute IRQ/packet processing across all available CPU cores
5. Adjust ring buffer sizes to absorb packet bursts
6. Verify the soft lockup condition is resolved

## Useful Commands

```bash
# Check current sysctl network settings
sysctl -a | grep -E "netdev_budget|backlog|rps"

# View interrupt affinity
cat /proc/irq/45/smp_affinity_list
cat /proc/irq/45/smp_affinity

# Check RPS configuration
cat /sys/class/net/eth0/queues/rx-0/rps_cpus

# View softnet stats (per-CPU packet processing stats)
cat /proc/net/softnet_stat

# Check ring buffer settings
ethtool -g eth0

# View NIC statistics for drops
ethtool -S eth0 | grep -i "drop\|miss\|err"

# Monitor softirq in real-time
watch -n1 'cat /proc/softirqs | grep NET_RX'

# Check NAPI and budget usage
cat /proc/net/dev
sar -n DEV 1 5

# View IRQ stats
watch -n1 'cat /proc/interrupts | grep eth0'

# Check ksoftirqd status
ps aux | grep ksoftirqd

# Monitor per-CPU softirq time
mpstat -P ALL 1

# Check if flow steering is enabled
ethtool -n eth0
ethtool -x eth0
```

## Hints

<details>
<summary>Hint 1</summary>
Look at <code>/proc/interrupts</code> carefully — notice ALL RX interrupts are being handled by CPU0 only. The other 7 CPUs are idle for network processing. Check the IRQ affinity settings and look at whether RPS (Receive Packet Steering) is configured.
</details>

<details>
<summary>Hint 2</summary>
The NAPI budget is set to only 10 packets per poll cycle via <code>net.core.netdev_budget</code>. At 2M packets/sec arriving on one CPU, this means the CPU can never drain the queue. The default should be 300, and for high-traffic servers 600-1200 is recommended. Also check <code>net.core.netdev_budget_usecs</code>.
</details>

<details>
<summary>Hint 3</summary>
The ring buffer (RX: 64) is absurdly small for a 10GbE NIC handling millions of packets. It should be 2048-4096. Combined with the single-CPU processing bottleneck, packets overflow the ring before they can be processed, causing the NIC to keep re-interrupting CPU0 in a tight loop.
</details>

## Root Causes

This lab has **four compounding issues**:

1. **`net.core.netdev_budget=10`** — NAPI can only process 10 packets per softirq cycle (default is 300). At high packet rates, the CPU spends all its time entering/exiting softirq context without making progress.

2. **No RPS/RSS configured** — All RX interrupts are pinned to CPU0 (the default when `smp_affinity` is `1` and `rps_cpus` is `0`). Seven other CPUs sit idle while one drowns.

3. **Ring buffer too small (RX=64)** — The NIC can only buffer 64 packets before dropping. At 2M pps, that's ~32 microseconds of buffer. Any processing delay causes packet loss and continuous interrupt storm.

4. **`net.core.netdev_max_backlog=128`** — Per-CPU input queue too small, causing drops even after packets make it past the ring buffer.
