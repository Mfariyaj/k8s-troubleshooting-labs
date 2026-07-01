# Solution: Lab 05 - Uneven Load Distribution

## Problem

Traffic is not being distributed evenly across backend servers. One server receives
all requests while others are idle.

## Diagnosis

```bash
# Send multiple requests and check which backend responds
for i in $(seq 1 20); do curl -s http://localhost/ | grep "server"; done

# Check the upstream configuration
grep -A10 "upstream" nginx.conf

# Check backend health
docker compose ps
```

## Root Cause

The upstream block uses `ip_hash` directive, which pins all requests from the same
client IP to the same backend. In testing or when behind another proxy, all traffic
appears to come from one IP and goes to one server.

## Fix

Edit `nginx.conf` — remove `ip_hash` or use `least_conn` for even distribution:

```nginx
upstream backend {
    # BROKEN: ip_hash;  # Pins all same-IP traffic to one server
    # FIXED: Use least_conn for even distribution
    least_conn;

    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
}
```

Alternative: Use default round-robin (just remove `ip_hash`):

```nginx
upstream backend {
    # No load balancing directive = round-robin (default)
    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Verify traffic is distributed across all backends
for i in $(seq 1 30); do curl -s http://localhost/ | grep "server"; done | sort | uniq -c

# Each server should get roughly equal traffic
# Example output:
#   10 server: backend1
#   10 server: backend2
#   10 server: backend3
```

## Key Takeaways

- `ip_hash` is only appropriate when session affinity is required
- `least_conn` distributes to the server with fewest active connections
- Default round-robin works well for stateless services
- Always test load distribution with multiple requests
- Consider `random two least_conn` for large upstream pools
