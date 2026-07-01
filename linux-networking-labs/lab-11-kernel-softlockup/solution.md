# Solution: Lab 11 - Kernel Soft Lockup / Network Packet Drops

## Problem

System reports kernel soft lockups and network performance degrades significantly.
Packet drops are observed under high network load.

## Diagnosis

```bash
# Check for soft lockup messages
dmesg | grep -i "soft lockup\|rcu\|hung_task"

# Check network interface statistics for drops
cat /proc/net/dev
ip -s link show

# Check current netdev_budget
sysctl net.core.netdev_budget

# Check ring buffer size
ethtool -g eth0

# Check RPS configuration
cat /sys/class/net/eth0/queues/rx-0/rps_cpus
```

## Root Cause

Under high network load, the system cannot process packets fast enough:
1. `netdev_budget` is too low — kernel processes too few packets per NAPI poll cycle.
2. RPS (Receive Packet Steering) not configured — all packets processed on one CPU.
3. Ring buffer too small — NIC drops packets before kernel can process them.

## Fix

### Step 1: Increase netdev_budget

```bash
sudo sysctl -w net.core.netdev_budget=600
sudo sysctl -w net.core.netdev_budget_usecs=8000
```

### Step 2: Configure RPS across all CPUs

```bash
# For a 4-CPU system, set RPS to use all CPUs (bitmask f = 1111)
echo "f" | sudo tee /sys/class/net/eth0/queues/rx-0/rps_cpus

# Set flow hash entries
echo 4096 | sudo tee /sys/class/net/eth0/queues/rx-0/rps_flow_cnt
sudo sysctl -w net.core.rps_sock_flow_entries=4096
```

### Step 3: Increase ring buffer

```bash
# Check maximum values
ethtool -g eth0

# Set to maximum
sudo ethtool -G eth0 rx 4096 tx 4096
```

### Step 4: Make persistent

```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-network-perf.conf
net.core.netdev_budget = 600
net.core.netdev_budget_usecs = 8000
net.core.rps_sock_flow_entries = 4096
EOF
sudo sysctl -p /etc/sysctl.d/99-network-perf.conf
```

## Verification

```bash
# Check drops are no longer increasing
ip -s link show eth0 | grep -A1 RX

# Verify settings
sysctl net.core.netdev_budget
ethtool -g eth0
cat /sys/class/net/eth0/queues/rx-0/rps_cpus
```

## Prevention

- Tune network stack as part of server provisioning
- Use multi-queue NICs with RSS (Receive Side Scaling)
- Monitor packet drop rates with alerting
- Set `net.core.netdev_budget` proportional to expected packet rate
