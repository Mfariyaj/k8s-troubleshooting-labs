# Solution: Lab 13 - HAProxy Stick Table Replication

## Problem

HAProxy stick tables are not replicating between peers. After failover, session
affinity is lost and users are routed to different backends.

## Diagnosis

```bash
# Check HAProxy stats
echo "show table be_app" | socat stdio /var/run/haproxy.sock

# Check peer status
echo "show peers" | socat stdio /var/run/haproxy.sock

# Check haproxy logs for peer errors
docker compose logs haproxy | grep "peer\|stick"

# Check the configuration
grep -A10 "peers\|stick-table" haproxy.cfg
```

## Root Cause

Three issues in the HAProxy configuration:
1. **Peer names don't match hostnames**: Peer names must exactly match the system
   hostname of each HAProxy instance.
2. **Wrong peer port**: The port specified for peers doesn't match the actual listening port.
3. **Stick-table size too small**: Table fills up and evicts entries, losing sessions.

## Fix

Edit `haproxy.cfg`:

```haproxy
# BROKEN: peer names don't match hostnames
# FIXED: Use actual hostnames
peers mycluster
    peer haproxy1 haproxy1:10000
    peer haproxy2 haproxy2:10000

frontend fe_main
    bind *:80
    default_backend be_app

backend be_app
    # BROKEN:  stick-table type ip size 100 expire 30m peers mycluster
    # FIXED:   Increase size and fix peer reference
    stick-table type ip size 100k expire 30m peers mycluster
    stick on src

    # Fix backend server ports
    server app1 backend1:3000 check
    server app2 backend2:3000 check
    server app3 backend3:3000 check
```

Then restart HAProxy:

```bash
docker compose restart haproxy1 haproxy2
```

## Verification

```bash
# Check peers are connected
echo "show peers" | socat stdio /var/run/haproxy.sock

# Verify stick table has entries
echo "show table be_app" | socat stdio /var/run/haproxy.sock

# Test session persistence across failover
curl -s http://localhost/ # Note which backend responds
# Stop one HAProxy, verify session still routes to same backend
```

## Key Takeaways

- HAProxy peer names MUST match the system hostname exactly
- Stick-table size should accommodate expected concurrent sessions
- Use `socat` to inspect live stick-table and peer state
- Peer ports must be consistent and reachable between instances
