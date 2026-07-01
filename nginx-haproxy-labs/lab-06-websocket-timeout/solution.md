# Solution: Lab 06 - WebSocket Timeout

## Problem

WebSocket connections are established but get disconnected after 60 seconds (nginx
default proxy timeout). The WebSocket server itself is working correctly.

## Diagnosis

```bash
# Test WebSocket connection (disconnects after ~60s)
websocat ws://localhost:80/ws

# Check nginx error log
docker compose logs nginx | grep "upstream timed out"

# Check current nginx proxy settings
grep -i "proxy_\|upgrade\|connection" nginx.conf
```

## Root Cause

Nginx proxy configuration is missing WebSocket-specific headers and has a short
read timeout:
1. Missing `proxy_http_version 1.1` — HTTP/1.0 doesn't support Upgrade
2. Missing `Upgrade` and `Connection` headers for the WebSocket handshake
3. Default `proxy_read_timeout` (60s) kills idle WebSocket connections

## Fix

Edit `nginx.conf`:

```nginx
location /ws {
    proxy_pass http://websocket_backend;

    # Required for WebSocket: use HTTP/1.1
    proxy_http_version 1.1;

    # Forward WebSocket upgrade headers
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Standard proxy headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;

    # Increase timeouts for long-lived connections
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test WebSocket stays connected beyond 60 seconds
websocat ws://localhost:80/ws
# Send messages and verify they work after >60s

# Or test with curl
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  http://localhost/ws
# Should return 101 Switching Protocols
```

## Key Takeaways

- WebSocket requires HTTP/1.1 — set `proxy_http_version 1.1`
- The `Upgrade` and `Connection` headers must be explicitly forwarded
- Default `proxy_read_timeout` (60s) is too short for WebSocket connections
- Set timeout based on expected idle time between messages
