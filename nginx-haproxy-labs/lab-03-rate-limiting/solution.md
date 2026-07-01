# Solution: Lab 03 - Rate Limiting Too Aggressive

## Problem

Legitimate traffic is being rate-limited (HTTP 429/503 responses) even at normal
request rates. Health check endpoints are also being throttled.

## Diagnosis

```bash
# Test the rate limit behavior
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost/; done

# Check nginx error log for limit_req entries
docker compose logs nginx | grep "limiting"
tail /var/log/nginx/error.log | grep "limit"

# Check the rate limit configuration
grep -A5 "limit_req" nginx.conf
```

## Root Cause

The rate limiting configuration is too aggressive:
1. Burst value is too low — even small traffic spikes get rejected.
2. Missing `nodelay` — requests queue up instead of being served immediately.
3. Health check endpoint is subject to the same rate limit as user traffic.

## Fix

Edit `nginx.conf`:

```nginx
# Increase burst and add nodelay
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    # Health check excluded from rate limiting
    location /health {
        # No limit_req here
        proxy_pass http://backend;
    }

    location / {
        # BROKEN:  limit_req zone=api burst=2;
        # FIXED:   Increase burst and add nodelay
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://backend;
    }
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test burst tolerance (should all return 200)
for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost/; done

# Health check should never be limited
for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code}\n" http://localhost/health; done

# Verify no spurious 429/503 in normal usage
ab -n 100 -c 10 http://localhost/
```

## Key Takeaways

- `burst` defines how many excess requests are queued beyond the rate
- `nodelay` serves burst requests immediately without queuing delay
- Always exclude health checks and monitoring endpoints from rate limits
- Use `limit_req_status 429` for proper HTTP status code
