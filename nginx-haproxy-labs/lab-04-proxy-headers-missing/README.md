## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 04: Proxy Headers Missing

## 🎯 Scenario

Your Nginx reverse proxy is forwarding requests to a backend application, but the app is reporting incorrect client information. The application relies on standard proxy headers (`X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`, `Host`) for security logging, HTTPS redirect decisions, and session management — but all headers show wrong or missing values.

**Difficulty:** ⭐⭐ Medium

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Test the endpoint
curl -s http://localhost:8084/ | jq .

# Expected: Headers showing your real IP, correct host, and protocol
# Actual: Internal container hostname, missing IP headers
```

### curl Response:
```json
{
  "received_headers": {
    "host": "backend:3000",
    "x-real-ip": "NOT SET",
    "x-forwarded-for": "NOT SET",
    "x-forwarded-proto": "NOT SET"
  },
  "issues": [
    "Host header shows internal service name instead of client-facing hostname",
    "X-Real-IP not set - cannot determine client IP for logging/security",
    "X-Forwarded-For not set - cannot track request chain",
    "X-Forwarded-Proto not set - cannot determine if original request was HTTPS"
  ],
  "status": "MISCONFIGURED"
}
```

### nginx -t Output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
When Nginx proxies a request, it doesn't automatically forward the original client's headers. By default, the Host header gets set to the upstream server name.
</details>

<details>
<summary>Hint 2</summary>
You need to explicitly set proxy headers using `proxy_set_header` directives in the location block.
</details>

<details>
<summary>Hint 3</summary>
The standard proxy headers to set are: `Host $host`, `X-Real-IP $remote_addr`, `X-Forwarded-For $proxy_add_x_forwarded_for`, and `X-Forwarded-Proto $scheme`.
</details>

---

## 🛠️ Useful Commands

```bash
# Test with custom Host header
curl -s -H "Host: myapp.example.com" http://localhost:8084/ | jq .

# Check what nginx is sending
docker-compose logs app

# View nginx config
docker exec lab-04-proxy-headers-missing-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
