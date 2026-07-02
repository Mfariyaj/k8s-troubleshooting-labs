## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 13: HAProxy Stick-Table Peer Replication Failure

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your organization runs two HAProxy instances in active-active configuration behind a network load balancer. Session persistence is maintained using stick-tables that replicate between peers. After a recent configuration change, users report:
- Sessions are "lost" every 10 seconds
- Traffic switching between HAProxy instances doesn't maintain server affinity
- Peers show as "disconnected" in stats
- The stick-table is constantly overflowing and evicting entries

The infrastructure team says "nothing changed" but peer replication is completely broken.

## Architecture

```
                    ┌─────────────────┐
                    │   NLB (L4)      │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
    ┌─────────▼─────────┐       ┌──────────▼────────┐
    │  HAProxy 1 (:8080)│◄─────►│  HAProxy 2 (:8081)│
    │  Peer port: 10000 │ SYNC  │  Peer port: 10000 │
    └─────────┬─────────┘       └──────────┬────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
    ┌─────────▼───┐  ┌──────▼──────┐  ┌───▼─────────┐
    │  Backend 1  │  │  Backend 2  │  │  Backend 3  │
    └─────────────┘  └─────────────┘  └─────────────┘
```

## What You'll Observe

### HAProxy startup logs:
```
[WARNING]  (1) : config : peers "mycluster" section doesn't match any local peer name
[ALERT]    (1) : config : peers "mycluster" has no local peer, cannot start peering
```

### Stick-table dump:
```bash
$ echo "show table http_back" | socat stdio tcp4:localhost:8080
# table: http_back, type: string, size:1024, used:0
```

### Session persistence test (fails):
```bash
$ for i in $(seq 1 10); do curl -s http://localhost:8080/ | grep server_id; sleep 2; done
"server_id":"backend1"
"server_id":"backend3"   <-- Different! Stick-table expired after 10s
"server_id":"backend2"   <-- Different! No persistence
"server_id":"backend1"
```

### HAProxy stats page:
```
Peers section: mycluster
  haproxy_node1: status=DISCONNECTED, msgs_sent=0, msgs_rcvd=0
  haproxy_node2: status=DISCONNECTED, msgs_sent=0, msgs_rcvd=0
```

## Hints

<details>
<summary>Hint 1</summary>
HAProxy peers require that the `peer` line name EXACTLY matches the hostname or the `-L` CLI parameter of the corresponding HAProxy process. If your container hostname is "haproxy1", the peer line must be `peer haproxy1 IP:PORT`, not `peer haproxy_node1 IP:PORT`. Check `hostname` inside each container.
</details>

<details>
<summary>Hint 2</summary>
Both peers must listen on the port specified in the peers section. If peer1's config says peer2 is on port 10001, but peer2 actually binds port 10000, the connection will fail. Verify the ports match in both directions and that each HAProxy binds the peer port.
</details>

<details>
<summary>Hint 3</summary>
The stick-table has multiple issues: `type string` is wrong for IP-based sticking (should be `type ip`), `size 1k` is far too small (entries get evicted immediately under any real load), and `expire 10s` means sessions are forgotten after 10 seconds of inactivity. For production, use `type ip`, `size 100k+`, and `expire 30m+`.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Test session persistence on haproxy1
for i in $(seq 1 10); do curl -s http://localhost:8080/ | jq -r .server_id; sleep 2; done

# Test session persistence on haproxy2 (should match haproxy1)
for i in $(seq 1 5); do curl -s http://localhost:8081/ | jq -r .server_id; done

# Check peer replication status
docker exec haproxy-peer1 sh -c "echo 'show peers' | socat stdio /dev/stdin" 2>/dev/null || \
docker logs haproxy-peer1 2>&1 | grep -i peer

# Dump stick-table contents
docker exec haproxy-peer1 sh -c "echo 'show table http_back' | socat stdio tcp4:127.0.0.1:8404" 2>/dev/null

# Check haproxy stats page
curl -s http://localhost:8404/stats | head -50

# Verify peer port connectivity
docker exec haproxy-peer1 nc -zv 172.25.0.11 10000
docker exec haproxy-peer1 nc -zv 172.25.0.11 10001

# Check container hostnames
docker exec haproxy-peer1 hostname
docker exec haproxy-peer2 hostname

# View HAProxy startup warnings/errors
docker logs haproxy-peer1 2>&1 | grep -E "WARNING|ALERT|ERROR"
docker logs haproxy-peer2 2>&1 | grep -E "WARNING|ALERT|ERROR"

# Monitor stick-table size (watch for overflow)
watch -n 1 'docker exec haproxy-peer1 sh -c "echo show table http_back | socat stdio tcp4:127.0.0.1:8404"'

# Generate load to fill stick-table (from different IPs)
for i in $(seq 1 100); do curl -s -H "X-Forwarded-For: 10.0.0.$i" http://localhost:8080/ > /dev/null; done

# Validate config syntax
docker exec haproxy-peer1 haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Clean up
./cleanup.sh
```

## Root Causes

There are **5 compounding issues** in this lab:

1. **Peers section name mismatch** — Peer names `haproxy_node1`/`haproxy_node2` don't match container hostnames `haproxy1`/`haproxy2`, so HAProxy can't identify which peer is "self"
2. **Peer port wrong** — Cross-references use port 10001 but HAProxy binds port 10000
3. **stick-table type wrong** — Using `type string` for source IP sticking instead of `type ip`
4. **expire too short (10s)** — Sessions forgotten after 10 seconds of inactivity
5. **stick-table size too small (1k)** — Only 1024 entries, causing constant eviction under load
