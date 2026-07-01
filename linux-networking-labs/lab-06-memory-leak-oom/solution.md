# Solution: Lab 06 - Memory Leak / OOM Kill

## Problem

A process continuously consumes memory until the OOM killer terminates it or the
system becomes unresponsive due to memory exhaustion.

## Diagnosis

```bash
# Check current memory usage
free -h

# Find the memory-hogging process
ps aux --sort=-%mem | head -10

# Check OOM killer logs
dmesg | grep -i "oom\|killed process"
journalctl -k | grep -i oom

# Monitor memory usage in real-time
top -o %MEM
```

## Root Cause

A process (memory-hog.py) has a memory leak — it continuously allocates memory
without releasing it. Without cgroup memory limits, it grows until the system
runs out of RAM and the OOM killer intervenes.

## Fix

### Step 1: Kill the memory-hogging process immediately

```bash
PID=$(ps aux --sort=-%mem | awk 'NR==2 {print $2}')
sudo kill -9 $PID
```

### Step 2: Set cgroup memory limits to prevent future OOM

```bash
# Create a cgroup with memory limit (cgroups v1)
sudo cgcreate -g memory:/app-limit
echo 512M | sudo tee /sys/fs/cgroup/memory/app-limit/memory.limit_in_bytes

# Run the process under the cgroup
sudo cgexec -g memory:/app-limit /path/to/process

# For systemd services, add to the unit file:
# [Service]
# MemoryMax=512M
# MemoryHigh=400M
```

### Step 3: Reload and restart with limits

```bash
sudo systemctl daemon-reload
sudo systemctl restart <service-name>
```

## Verification

```bash
# Confirm memory is freed
free -h

# Check process is gone
ps aux | grep memory-hog

# Verify cgroup limits are applied
cat /sys/fs/cgroup/memory/app-limit/memory.limit_in_bytes
```

## Prevention

- Set `MemoryMax=` in systemd service units
- Use cgroup memory limits for all production workloads
- Implement memory usage monitoring and alerting
- Profile applications for memory leaks during development
