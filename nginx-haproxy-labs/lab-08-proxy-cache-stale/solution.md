# Solution: Lab 08 - Proxy Cache Serving Stale/Wrong Content

## Problem

Users receive cached content meant for other users. Personalized pages (e.g., dashboard)
show another user's data. Session-specific content is being shared across users.

## Diagnosis

```bash
# Test with different cookies/sessions
curl -H "Cookie: session=user1" http://localhost/dashboard
curl -H "Cookie: session=user2" http://localhost/dashboard
# Both return the same cached content!

# Check cache configuration
grep -A10 "proxy_cache" nginx.conf

# Check what's being used as the cache key
grep "proxy_cache_key" nginx.conf
```

## Root Cause

The `proxy_cache_key` does not include session-specific identifiers. All users
share the same cache entry because the key is only based on URI. The `Vary` header
is also not configured to differentiate cached responses.

## Fix

Edit `nginx.conf`:

```nginx
proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=app_cache:10m
                 max_size=100m inactive=60m;

server {
    location / {
        proxy_pass http://backend;
        proxy_cache app_cache;

        # BROKEN:  proxy_cache_key "$scheme$request_method$host$request_uri";
        # FIXED:   Include session cookie in the cache key
        proxy_cache_key "$scheme$request_method$host$request_uri$cookie_session";

        # Add Vary header to signal caches about session-dependent content
        add_header Vary "Cookie";

        # Add cache status header for debugging
        add_header X-Cache-Status $upstream_cache_status;
    }

    # Don't cache authenticated/personalized endpoints
    location /dashboard {
        proxy_pass http://backend;
        proxy_cache app_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$cookie_session";
        add_header Vary "Cookie";
    }
}
```

Then reload:

```bash
# Clear existing cache
sudo rm -rf /tmp/nginx_cache/*
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Different sessions should get different content
curl -H "Cookie: session=user1" http://localhost/dashboard
curl -H "Cookie: session=user2" http://localhost/dashboard

# Check cache status header
curl -I -H "Cookie: session=user1" http://localhost/dashboard | grep X-Cache
```

## Key Takeaways

- Default `proxy_cache_key` doesn't include cookies — all users share cache entries
- Always include session identifiers in cache keys for personalized content
- Use `Vary` header to inform downstream caches about response variations
- Consider `proxy_no_cache` for highly dynamic/personalized endpoints
- Add `X-Cache-Status` header for debugging cache behavior
