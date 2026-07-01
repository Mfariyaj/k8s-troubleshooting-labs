# Solution: Lab 10 - Connection Timeouts Under Load

## Problem

Under high concurrent load, nginx starts returning 502/504 errors or clients
experience connection timeouts. The backend itself can handle the load.

## Diagnosis

```bash
# Load test
./load-test.sh
# Or: ab -n 10000 -c 500 http://localhost/

# Check nginx error log
tail /var/log/nginx/error.log
# Errors like: "worker_connections are not enough" or "no live upstreams"

# Check current worker_connections
grep worker_connections nginx.conf

# Check upstream keepalive configuration
grep -A10 "upstream" nginx.conf
```

## Root Cause

1. **`worker_connections` too low**: Default 512 or 1024 limits total simultaneous
   connections per worker process. Each proxy request uses 2 connections (client + upstream).
2. **No keepalive to upstream**: Every request opens a new TCP connection to the
   backend, adding latency and exhausting connections.

## Fix

Edit `nginx.conf`:

```nginx
events {
    # BROKEN:  worker_connections 512;
    # FIXED:
    worker_connections 4096;
}

http {
    upstream backend {
        server app:3000;
        # Add connection pooling to upstream
        keepalive 64;
    }

    server {
        location / {
            proxy_pass http://backend;
            # Required for upstream keepalive
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Run load test again — should handle without errors
ab -n 10000 -c 500 http://localhost/

# Check for 502/504 errors in logs
grep -c "502\|504" /var/log/nginx/error.log

# Monitor active connections
curl http://localhost/nginx_status
```

## Key Takeaways

- Each proxy connection uses 2 file descriptors (client-side + upstream-side)
- `worker_connections` should be >= 2x expected concurrent clients per worker
- `keepalive` in upstream block reuses TCP connections, reducing latency
- Must set `proxy_http_version 1.1` and clear `Connection` header for keepalive
- Also check `worker_rlimit_nofile` matches or exceeds `worker_connections`
