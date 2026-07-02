## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 06: WebSocket Timeout

## 🎯 Scenario

You've deployed a WebSocket echo server behind Nginx. HTTP requests work fine, but WebSocket connections **fail to establish** or **get disconnected after 60 seconds**. The WebSocket server works correctly when accessed directly, but breaks when proxied through Nginx.

**Difficulty:** ⭐⭐⭐ Hard

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# HTTP works fine
curl -s http://localhost:8086/ | jq .

# WebSocket connection fails
# Using curl to attempt WebSocket upgrade:
curl -v -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  http://localhost:8086/

# Expected: 101 Switching Protocols
# Actual: 200 OK (upgrade not happening) or connection drops
```

### Error Log Output:
```
[error] upstream prematurely closed connection while reading response header
from upstream, client: 172.18.0.1, server: localhost, request: "GET / HTTP/1.1"
```

### Observed Behavior:
```
< HTTP/1.1 200 OK
(WebSocket upgrade is silently ignored, returns regular HTTP response)
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
By default, Nginx uses HTTP/1.0 for upstream connections. The WebSocket protocol requires HTTP/1.1 because the Upgrade mechanism is only available in HTTP/1.1.
</details>

<details>
<summary>Hint 2</summary>
Nginx doesn't forward the `Upgrade` and `Connection` headers to the upstream by default. You need to explicitly pass them through with `proxy_set_header`.
</details>

<details>
<summary>Hint 3</summary>
Three things need to be set: (1) `proxy_http_version 1.1;`, (2) `proxy_set_header Upgrade $http_upgrade;`, (3) `proxy_set_header Connection "upgrade";`. Also consider increasing `proxy_read_timeout` for long-lived connections.
</details>

---

## 🛠️ Useful Commands

```bash
# Test regular HTTP
curl -s http://localhost:8086/

# Test WebSocket upgrade attempt
curl -v -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  http://localhost:8086/

# Check nginx error logs
docker exec lab-06-websocket-timeout-nginx-1 cat /var/log/nginx/error.log

# Check ws-server logs
docker-compose logs ws-server

# View nginx config
docker exec lab-06-websocket-timeout-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
