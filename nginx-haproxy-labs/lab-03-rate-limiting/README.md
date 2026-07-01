# Lab 03: Rate Limiting Blocking Health Checks

## 🎯 Scenario

You've configured rate limiting on your Nginx reverse proxy to protect your backend from abuse. However, your monitoring system reports that the application is "unhealthy" because health check endpoints are returning **429 Too Many Requests**. Real user traffic is also being rejected even at low volumes.

**Difficulty:** ⭐⭐ Medium

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Make a few rapid requests
for i in {1..5}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8083/; done

# Check health endpoint
for i in {1..5}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8083/health; done

# Expected: Health checks always return 200
# Actual: Most requests return 429 Too Many Requests
```

### Error Log Output:
```
[error] limiting requests, excess: 0.984 by zone "global_limit",
client: 172.18.0.4, server: localhost, request: "GET /health HTTP/1.1", host: "nginx"
```

### curl Response:
```
HTTP/1.1 429 Too Many Requests
< Connection: keep-alive
<
<html>
<head><title>429 Too Many Requests</title></head>
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
The rate limit is set to 1 request per second with burst=0. That means ANY second request within the same second is immediately rejected. Is that reasonable for health checks?
</details>

<details>
<summary>Hint 2</summary>
Health check endpoints should typically be exempt from rate limiting. Can you use a separate location block without the limit_req directive?
</details>

<details>
<summary>Hint 3</summary>
Consider: (1) Exempt health checks from rate limiting, (2) Increase the burst value so legitimate traffic isn't blocked, (3) Use `limit_req_zone` with a more reasonable rate for general traffic.
</details>

---

## 🛠️ Useful Commands

```bash
# Watch health check container logs
docker-compose logs -f healthcheck

# Check rate of 429s in nginx logs
docker exec lab-03-rate-limiting-nginx-1 cat /var/log/nginx/error.log | grep "limiting requests"

# Rapid fire test
for i in {1..10}; do echo "Request $i: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:8083/api)"; done

# View nginx config
docker exec lab-03-rate-limiting-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
