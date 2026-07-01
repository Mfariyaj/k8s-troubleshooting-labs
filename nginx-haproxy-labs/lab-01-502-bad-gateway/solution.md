# Solution: Lab 01 - 502 Bad Gateway

## Problem

Nginx returns "502 Bad Gateway" for all requests proxied to the backend application.

## Diagnosis

```bash
# Check nginx error log
docker compose logs nginx | grep "502\|upstream\|connect"

# Or on the host
tail -f /var/log/nginx/error.log

# Check if backend is running and what port it listens on
docker compose ps
docker compose logs app

# Test backend directly
curl http://localhost:3000

# Check the nginx upstream configuration
cat nginx.conf | grep -A5 upstream
```

## Root Cause

The nginx configuration proxies to the backend on port **3001**, but the backend
application actually listens on port **3000**. Nginx cannot connect to the upstream
and returns 502.

## Fix

Edit `nginx.conf` and correct the upstream port:

```nginx
upstream backend {
    # BROKEN:  server app:3001;
    # FIXED:
    server app:3000;
}
```

Then reload nginx:

```bash
docker compose restart nginx
# Or if running on host:
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test the proxy works
curl -I http://localhost:80

# Should return 200 OK instead of 502
curl http://localhost/

# Check nginx error log is clean
docker compose logs nginx | tail -5
```

## Key Takeaways

- 502 means nginx reached the upstream but got no valid response (connection refused)
- Always verify the backend port matches what nginx is configured to proxy to
- Use `docker compose ps` to check exposed ports
- `nginx -t` validates config syntax but not upstream connectivity
