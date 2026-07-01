# Solution: Lab 09 - TCP Port Exhaustion

## Problem

New outbound TCP connections fail with "Cannot assign requested address". The system
has exhausted its ephemeral port range.

## Diagnosis

```bash
# Check connection states
ss -s

# Count TIME_WAIT connections
ss -tan | grep TIME-WAIT | wc -l

# Check current ephemeral port range
cat /proc/sys/net/ipv4/ip_local_port_range

# Check tcp_tw_reuse setting
cat /proc/sys/net/ipv4/tcp_tw_reuse

# View connections by state
ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn
```

## Root Cause

The ephemeral port range is too small (default 32768-60999 = ~28000 ports), and
thousands of connections in TIME_WAIT state hold ports for 60 seconds. High-throughput
applications quickly exhaust available ports.

## Fix

### Step 1: Increase the ephemeral port range

```bash
sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535"
```

### Step 2: Enable TCP TIME_WAIT reuse

```bash
sudo sysctl -w net.ipv4.tcp_tw_reuse=1
```

### Step 3: Reduce FIN timeout

```bash
sudo sysctl -w net.ipv4.tcp_fin_timeout=15
```

### Step 4: Make changes persistent

```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-port-exhaustion.conf
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
EOF
sudo sysctl -p /etc/sysctl.d/99-port-exhaustion.conf
```

## Verification

```bash
# Confirm new settings
sysctl net.ipv4.ip_local_port_range
sysctl net.ipv4.tcp_tw_reuse

# Monitor TIME_WAIT count
watch -n 5 'ss -tan | grep TIME-WAIT | wc -l'

# Test new connections succeed
curl http://example.com
```

## Prevention

- Use connection pooling (HTTP keep-alive, database connection pools)
- Set wider port ranges by default in system provisioning
- Enable `tcp_tw_reuse` on systems making many outbound connections
- Monitor ephemeral port usage with Prometheus node_exporter
