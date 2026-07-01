# Lab 15: Dynamic Upstream DNS Resolution with Stale IPs

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform uses Nginx as a reverse proxy with service discovery via Consul DNS. When backends scale down (or get new IPs during deployments), Nginx continues sending traffic to the old/dead IP addresses for extended periods. This causes cascading 502 errors during deployments and autoscaling events.

The infrastructure team has configured a resolver block and Consul DNS, but the DNS caching and upstream resolution behavior isn't working as expected. Backend services have a DNS TTL of 5 seconds, but stale entries persist for 30+ seconds.

## Architecture

```
                    ┌──────────────────────────────┐
                    │         Nginx (:8080)         │
                    │                              │
                    │  upstream backend_pool {     │
                    │    server 172.28.0.20:80;    │  ← Static! Resolved at startup
                    │    server 172.28.0.21:80;    │
                    │    server 172.28.0.22:80;    │
                    │  }                           │
                    │                              │
                    │  resolver 127.0.0.11         │
                    │          valid=30s ipv6=on;  │  ← Overrides DNS TTL
                    └──────────────┬───────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
    ┌─────────▼───┐      ┌────────▼────┐     ┌────────▼────┐
    │  Backend 1  │      │  Backend 2  │     │  Backend 3  │
    │ 172.28.0.20 │      │ 172.28.0.21 │     │ 172.28.0.22 │
    └─────────────┘      └─────────────┘     └─────────────┘
              │
    ┌─────────▼───────────────────────────────────────────┐
    │              Consul DNS (port 8600)                  │
    │  backend.service.consul → [172.28.0.20, .21, .22]  │
    │  TTL: 5s                                            │
    └─────────────────────────────────────────────────────┘
```

## What You'll Observe

### Initially everything works:
```bash
$ for i in $(seq 1 6); do curl -s http://localhost:8080/ | jq -r .instance_ip; done
172.28.0.20
172.28.0.21
172.28.0.22
172.28.0.20
172.28.0.21
172.28.0.22
```

### After stopping backend3:
```bash
$ docker stop dns-backend3
$ for i in $(seq 1 10); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/; sleep 1; done
200
200
502    ← Traffic still going to dead 172.28.0.22
200
502    ← Still happening 30+ seconds later
200
502
200
200
502
```

### DNS shows correct results (backend3 gone):
```bash
$ docker exec dns-nginx nslookup backend.service.consul 172.28.0.2
Name:      backend.service.consul
Address 1: 172.28.0.20
Address 2: 172.28.0.21
# Note: 172.28.0.22 is gone from DNS but Nginx still uses it
```

### Nginx error.log:
```
2024/03/15 16:00:05 [error] 7#7: *89 connect() failed (113: No route to host) while connecting to upstream, upstream: "http://172.28.0.22:80"
2024/03/15 16:00:05 [error] 7#7: *90 no live upstreams while connecting to upstream
2024/03/15 16:00:06 [error] 7#7: *91 backend.service.consul could not be resolved (110: Operation timed out) while resolving, resolver: 127.0.0.11:53
2024/03/15 16:00:07 [error] 7#7: *92 ipv6 resolution failed (ServFail) while resolving, resolver: 127.0.0.11:53
```

## Hints

<details>
<summary>Hint 1</summary>
The `upstream` block with static `server` directives resolves IPs once at config load time. It does NOT re-resolve on each request regardless of what the `resolver` directive says. The resolver block only applies when proxy_pass uses a VARIABLE. To get per-request DNS resolution, you need: `set $backend "http://backend.service.consul"; proxy_pass $backend;`
</details>

<details>
<summary>Hint 2</summary>
The `resolver ... valid=30s` overrides the DNS record's TTL. Even if Consul returns records with TTL=5s, Nginx will cache them for 30 seconds. For dynamic service discovery, `valid` should match or be shorter than the DNS TTL. Also, `ipv6=on` causes AAAA lookups that fail in IPv4-only Docker networks, adding latency and error log noise.
</details>

<details>
<summary>Hint 3</summary>
For truly dynamic upstream management in open-source Nginx, you need: (1) a variable in proxy_pass (forces per-request resolution), (2) resolver with appropriate valid time, (3) ipv6=off in IPv4-only environments, and (4) if using upstream block, the `zone` directive to enable shared memory for dynamic updates. The static upstream block + keepalive approach is fundamentally incompatible with dynamic service discovery.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Test load balancing
for i in $(seq 1 10); do curl -s http://localhost:8080/ | jq -r .instance_ip; done

# Scale down backend3 and observe stale routing
docker stop dns-backend3
for i in $(seq 1 15); do curl -s -o /dev/null -w "%{http_code} " http://localhost:8080/; sleep 1; done; echo

# Check DNS resolution from nginx container
docker exec dns-nginx nslookup backend.service.consul 172.28.0.2

# Query Consul DNS directly
dig @localhost -p 8600 backend.service.consul A +short

# Check Consul service catalog
curl -s http://localhost:8500/v1/catalog/service/backend | jq '.[].Address'

# View Nginx upstream state
docker exec dns-nginx cat /proc/1/fd/2 2>/dev/null

# Test the /dynamic location (uses variable-based proxy_pass)
for i in $(seq 1 5); do curl -s http://localhost:8080/dynamic | jq -r .instance_ip; done

# Monitor error logs for stale IP connections
docker exec dns-nginx tail -f /var/log/nginx/error.log

# Restart backend3 and verify recovery time
docker start dns-backend3
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code} " http://localhost:8080/; sleep 1; done; echo

# Scale by adding backend4
docker run -d --name dns-backend4 --network lab-15-dynamic-upstream-dns_dns-net \
  --ip 172.28.0.23 nginx:1.25-alpine

# Deregister from Consul
curl -s -X PUT http://localhost:8500/v1/agent/service/deregister/backend3

# Check resolver behavior
docker exec dns-nginx cat /var/log/nginx/error.log | grep -i "resolv\|dns\|ipv6"

# Verify nginx config
docker exec dns-nginx nginx -t

# Clean up
./cleanup.sh
```

## Root Causes

There are **5 compounding issues** in this lab:

1. **Static upstream IPs** — The `upstream` block uses hardcoded `server` IPs that are resolved only once at config load; changes require `nginx -s reload`
2. **resolver valid=30s vs DNS TTL=5s** — Nginx caches DNS for 30 seconds even though records have 5s TTL, causing stale entries
3. **proxy_pass without variable** — Using `proxy_pass http://upstream_name` never re-resolves DNS; must use a variable (`set $backend "..."; proxy_pass $backend;`)
4. **No upstream zone** — Without `zone` directive, upstream state can't be shared between workers or updated dynamically
5. **resolver ipv6=on** — Causes AAAA lookups that fail in IPv4-only Docker network, adding latency and filling error logs
