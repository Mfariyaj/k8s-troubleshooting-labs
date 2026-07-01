# Solution: Lab 08 - Swap Thrashing

## Problem

System is extremely slow and unresponsive. High I/O wait, and the system is heavily
swapping — constantly moving pages between RAM and swap space.

## Diagnosis

```bash
# Check memory and swap usage
free -h

# Check swap activity (si/so columns)
vmstat 1 5

# Identify the process consuming the most memory
ps aux --sort=-%mem | head -10

# Check swappiness value
cat /proc/sys/vm/swappiness

# Monitor I/O wait
iostat -x 1 3
```

## Root Cause

A memory-hungry process is consuming most of available RAM, forcing the kernel to
aggressively swap other processes. High `vm.swappiness` (default 60) makes the
kernel prefer swapping over reclaiming page cache.

## Fix

### Step 1: Kill the memory-hungry process

```bash
PID=$(ps aux --sort=-%mem | awk 'NR==2 {print $2}')
sudo kill $PID
```

### Step 2: Adjust vm.swappiness

```bash
# Reduce swappiness (lower = prefer killing over swapping)
sudo sysctl vm.swappiness=10

# Make persistent
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf
```

### Step 3: Clear swap (if system has enough free RAM now)

```bash
sudo swapoff -a && sudo swapon -a
```

### Step 4 (Long-term): Add more RAM or set memory limits

```bash
# For the service, add memory limits in systemd unit:
# MemoryMax=2G
# MemoryHigh=1.5G
```

## Verification

```bash
# Check swap usage is reduced
free -h

# Verify swappiness setting
cat /proc/sys/vm/swappiness

# Monitor — si/so should be near zero
vmstat 1 5
```

## Prevention

- Set `vm.swappiness=10` on production servers
- Implement memory limits for all services via cgroups/systemd
- Monitor swap usage and alert when swap exceeds 50%
- Size RAM appropriately for workload requirements
