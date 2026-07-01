# Solution: Lab 09 - Infinite Redirect Loop

## Problem

Requests result in "ERR_TOO_MANY_REDIRECTS" or the browser shows "This page has
too many redirects". The response is a chain of 301/302 redirects.

## Diagnosis

```bash
# Follow redirects and observe the loop
curl -L -v http://localhost/ 2>&1 | grep "< Location"

# See the redirect chain without following
curl -I http://localhost/
curl -I https://localhost/

# Check nginx config for redirects
grep -i "return\|rewrite\|redirect" nginx.conf

# Check backend application for redirects
docker compose logs app | grep "redirect\|301\|302"
```

## Root Cause

Both nginx AND the backend application are performing HTTP→HTTPS redirects:
1. Nginx has `return 301 https://$host$request_uri`
2. The backend also detects non-HTTPS (via missing X-Forwarded-Proto) and redirects

The loop: Client → nginx (redirect to HTTPS) → nginx (proxy to backend) →
backend (sees no X-Forwarded-Proto, redirects to HTTPS) → infinite loop.

## Fix

Remove ONE of the redirects. Keep the redirect in nginx (preferred) and remove it
from the backend, OR pass `X-Forwarded-Proto` so the backend knows it's already HTTPS:

### Option 1: Remove redirect from nginx, let backend handle it

```nginx
server {
    listen 80;
    # Remove: return 301 https://$host$request_uri;
    location / {
        proxy_pass http://backend;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Option 2 (Preferred): Keep nginx redirect, inform backend of proto

```nginx
server {
    listen 443 ssl;
    location / {
        proxy_pass http://backend;
        # Tell backend it's already HTTPS — don't redirect again
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Host $host;
    }
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Should get a single redirect or direct 200 — no loop
curl -I http://localhost/
curl -L -o /dev/null -w "%{http_code}" http://localhost/

# Should return 200, not redirect chain
curl -k https://localhost/
```

## Key Takeaways

- Only ONE layer should perform HTTP→HTTPS redirect
- Always pass `X-Forwarded-Proto` so backends know the original protocol
- Use `curl -L -v` to trace redirect chains
- Max redirect limit in browsers is typically 20
