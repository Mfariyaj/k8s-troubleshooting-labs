# Solution: Lab 15 - Dynamic Upstream DNS Resolution

## Problem

When backend services scale up/down or change IP addresses, nginx continues routing
to stale IPs. DNS changes are not picked up without a full reload.

## Diagnosis

```bash
# Check upstream resolution
docker compose logs nginx | grep "resolve\|upstream\|host not found"

# Nginx resolves DNS only at startup (or reload) for static upstreams
# Scale backends and observe stale routing
docker compose scale backend=3
curl http://localhost/  # Still goes to old IPs

# Check nginx configuration
grep -A5 "upstream\|resolver" nginx.conf
```

## Root Cause

Nginx resolves upstream server DNS entries only at config load time for static
`upstream` blocks. When backends change IPs (container restarts, scaling), nginx
doesn't re-resolve DNS. There's also no `resolver` directive configured for
runtime resolution.

## Fix

Edit `nginx.conf` to use variables for dynamic DNS resolution:

```nginx
http {
    # Add a resolver for runtime DNS lookups
    resolver 127.0.0.11 valid=10s ipv6=off;  # Docker's DNS (or 8.8.8.8)
    resolver_timeout 5s;

    # Use upstream zone for shared memory
    upstream backend {
        zone backend_zone 64k;
        server backend:3000 resolve;  # Requires nginx plus or use variable method
    }

    # Alternative: Use variable in proxy_pass for dynamic resolution
    server {
        listen 80;

        location / {
            # Using a variable forces DNS re-resolution on each request
            set $backend_host "backend";
            proxy_pass http://$backend_host:3000;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
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
# Scale backends
docker compose scale backend=3

# Verify traffic reaches new backends (wait for DNS TTL)
sleep 15
for i in $(seq 1 10); do curl -s http://localhost/ | grep server; done

# Check resolver is working
docker compose logs nginx | grep -i "resolve"
```

## Key Takeaways

- Static `upstream` blocks resolve DNS only at startup/reload
- Using a variable in `proxy_pass` triggers per-request DNS resolution
- Always configure `resolver` directive when using variable-based proxy_pass
- `valid=Ns` controls how long nginx caches DNS responses
- For Nginx Plus, use `resolve` parameter in upstream server directive
- The `zone` directive enables shared memory for upstream state
