# Solution: Lab 12 - Network Namespace Leaked

## Problem

Orphaned network namespaces accumulate, exhausting IPAM allocations and leaving
stale veth pairs that prevent new containers/pods from getting IP addresses.

## Diagnosis

```bash
# List all network namespaces
ip netns list

# Check for orphaned namespaces (no running process inside)
for ns in $(ip netns list | awk '{print $1}'); do
  if ! ip netns pids "$ns" 2>/dev/null | grep -q .; then
    echo "ORPHAN: $ns"
  fi
done

# Check IPAM allocations
ls /var/lib/cni/networks/

# Check for stale veth pairs
ip link show type veth

# Check available IPs in the range
cat /var/lib/cni/networks/*/last_reserved_ip
```

## Root Cause

Container runtimes crashed or were forcefully stopped without proper cleanup.
Network namespaces, veth pairs, and IPAM allocations remain even though the
containers no longer exist. The IP address pool eventually gets exhausted.

## Fix

### Step 1: Delete orphaned namespaces

```bash
# Delete each orphaned namespace
for ns in $(ip netns list | awk '{print $1}'); do
  if ! ip netns pids "$ns" 2>/dev/null | grep -q .; then
    echo "Deleting orphan namespace: $ns"
    sudo ip netns delete "$ns"
  fi
done
```

### Step 2: Free IPAM allocations

```bash
# Remove stale IPAM entries (check which IPs belong to dead containers)
sudo find /var/lib/cni/networks/ -type f ! -name "last_reserved_ip" \
  -exec sh -c 'PID=$(cat "$1"); kill -0 $PID 2>/dev/null || rm "$1"' _ {} \;
```

### Step 3: Clean stale veth pairs

```bash
# Remove veth pairs that have no peer in any namespace
for veth in $(ip link show type veth | grep "^[0-9]" | awk -F: '{print $2}' | tr -d ' '); do
  if ip link show "$veth" 2>/dev/null | grep -q "NOARP"; then
    sudo ip link delete "$veth"
  fi
done
```

## Verification

```bash
# Confirm namespaces are cleaned
ip netns list

# Confirm IPAM has free IPs
ls /var/lib/cni/networks/*/ | wc -l

# Verify new containers can get IPs
docker run --rm alpine ip addr
```

## Prevention

- Use container runtimes with proper garbage collection
- Run periodic cleanup scripts via cron
- Monitor IPAM pool utilization with alerts
- Ensure graceful shutdown procedures for container runtimes
