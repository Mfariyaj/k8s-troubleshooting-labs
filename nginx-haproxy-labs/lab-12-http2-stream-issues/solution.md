# Solution: Lab 12 - HTTP/2 Stream Issues

## Problem

HTTP/2 connections experience stream resets, multiplexing failures, or "ENHANCE_YOUR_CALM"
errors under concurrent requests. Single requests work but parallel ones fail.

## Diagnosis

```bash
# Test with HTTP/2 and multiple streams
curl --http2 -v https://localhost/

# Test parallel requests
curl --http2 --parallel --parallel-max 200 \
  https://localhost/api/{1..100}

# Check nginx error log
docker compose logs nginx | grep "http2\|stream\|RST_STREAM"

# Check current HTTP/2 settings
grep "http2" nginx.conf
```

## Root Cause

1. `http2_max_concurrent_streams` is too low — limits how many parallel requests
   a single HTTP/2 connection can multiplex.
2. Nginx proxies to the backend using HTTP/1.1 instead of HTTP/2, losing
   multiplexing benefits on the upstream side.

## Fix

Edit `nginx.conf`:

```nginx
http {
    # Increase max concurrent streams per connection
    # BROKEN:  http2_max_concurrent_streams 10;
    # FIXED:
    http2_max_concurrent_streams 256;

    server {
        listen 443 ssl http2;

        location / {
            # Use HTTP/2 to upstream (if backend supports it)
            # For gRPC or HTTP/2 backends:
            grpc_pass grpc://backend;
            # Or for HTTP/2 proxy:
            proxy_pass https://backend;
            proxy_http_version 1.1;  # Use 1.1 with keepalive if backend is HTTP/1
        }
    }
}
```

For HTTP/1.1 backends, optimize connection reuse:

```nginx
upstream backend {
    server app:3000;
    keepalive 128;
}

location / {
    proxy_pass http://backend;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test many parallel HTTP/2 streams
curl --http2 --parallel --parallel-max 100 \
  https://localhost/api/{1..50}

# Check for stream errors
curl --http2 -v https://localhost/ 2>&1 | grep "SETTINGS\|stream"

# Verify HTTP/2 is active
curl -I --http2 https://localhost/ | grep HTTP
```

## Key Takeaways

- Default `http2_max_concurrent_streams` (128) may be too low for heavy multiplexing
- Nginx currently proxies to upstream using HTTP/1.1 (use keepalive to compensate)
- For gRPC, use `grpc_pass` which speaks HTTP/2 natively
- Monitor stream resets and GOAWAY frames in error logs
