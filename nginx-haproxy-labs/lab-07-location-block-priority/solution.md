# Solution: Lab 07 - Location Block Priority

## Problem

Requests are matching unexpected location blocks. For example, `/api/users` is
served by the wrong handler, or static files are being proxied to the backend.

## Diagnosis

```bash
# Test which location handles different paths
curl -I http://localhost/api/users
curl -I http://localhost/static/style.css
curl -I http://localhost/api

# Add debug headers to identify which block matched
# Check nginx configuration
cat nginx.conf | grep -A3 "location"
```

## Root Cause

Nginx location matching follows a specific priority order that is not intuitive:
1. `= /path` — Exact match (highest priority)
2. `^~ /path` — Prefix match, stops regex search
3. `~ regex` / `~* regex` — Regular expression (case-sensitive/insensitive)
4. `/path` — Prefix match (lowest priority)

The blocks are ordered incorrectly, causing regex patterns to override intended
prefix matches, or broader prefixes to catch traffic meant for more specific ones.

## Fix

Reorder location blocks understanding the priority rules:

```nginx
server {
    listen 80;

    # Exact match — highest priority
    location = / {
        return 200 "homepage";
    }

    # Prefix match that prevents regex from overriding
    location ^~ /static/ {
        root /var/www;
    }

    # Regex matches (evaluated in order they appear)
    location ~ \.php$ {
        fastcgi_pass php:9000;
    }

    # Standard prefix matches
    location /api/ {
        proxy_pass http://backend;
    }

    # Default fallback
    location / {
        try_files $uri $uri/ =404;
    }
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Verify each path hits the correct handler
curl http://localhost/            # Should hit exact match
curl http://localhost/static/x.css  # Should serve static file
curl http://localhost/api/users   # Should proxy to backend
curl http://localhost/test.php    # Should go to PHP handler
```

## Key Takeaways

- Priority: `=` > `^~` > `~`/`~*` > prefix
- Use `^~` to prevent regex from overriding a prefix location
- Regex locations are evaluated in config file order (first match wins)
- Use `= /` for exact homepage matches to avoid ambiguity
- Add `add_header X-Location "block-name"` for debugging
