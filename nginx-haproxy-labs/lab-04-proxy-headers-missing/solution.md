# Solution: Lab 04 - Proxy Headers Missing

## Problem

The backend application cannot determine the client's real IP address, protocol
(HTTP/HTTPS), or original hostname. It sees nginx's IP and internal values instead.

## Diagnosis

```bash
# Check what the backend sees
curl http://localhost/ | python3 -m json.tool

# Look at the app's received headers
docker compose logs app | grep -i "x-real\|x-forwarded\|host"

# Check nginx configuration for proxy_set_header
grep "proxy_set_header" nginx.conf
```

## Root Cause

The nginx proxy configuration doesn't forward essential client information headers.
Without `proxy_set_header`, the backend receives:
- `Host: backend:3000` (internal container name instead of original)
- No `X-Real-IP` (sees nginx's IP as client)
- No `X-Forwarded-Proto` (can't detect HTTPS for secure redirects)

## Fix

Edit `nginx.conf` to add the required proxy headers:

```nginx
location / {
    proxy_pass http://backend;

    # Forward the original Host header
    proxy_set_header Host $host;

    # Forward the real client IP
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # Forward the original protocol (http/https)
    proxy_set_header X-Forwarded-Proto $scheme;

    # Forward the original port
    proxy_set_header X-Forwarded-Port $server_port;
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Check backend now receives correct headers
curl -H "Host: myapp.example.com" http://localhost/

# Verify X-Forwarded-For contains your IP
curl http://localhost/headers

# Check logs show real client IP
docker compose logs app | tail -5
```

## Key Takeaways

- Without `proxy_set_header Host`, the backend gets the upstream name
- `X-Real-IP` and `X-Forwarded-For` are critical for logging and access control
- `X-Forwarded-Proto` is needed for secure cookie/redirect decisions
- These headers should be set in every reverse proxy configuration
