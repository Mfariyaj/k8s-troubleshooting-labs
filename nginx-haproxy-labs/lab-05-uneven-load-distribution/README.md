# Lab 05: Uneven Load Distribution

## 🎯 Scenario

You've set up Nginx as a load balancer in front of 3 backend servers. However, monitoring shows that **all traffic is hitting a single backend** while the other two are idle. The load balancer is supposed to distribute requests evenly across all three backends.

**Difficulty:** ⭐⭐⭐ Hard

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Send 20 requests and observe which backend responds
for i in {1..20}; do curl -s http://localhost:8085/ | jq -r '.server_id'; done | sort | uniq -c

# Expected: ~7 requests per backend (even distribution)
# Actual: All 20 requests go to the same backend
```

### curl Response:
```json
{
  "server_id": "backend-1",
  "request_number": 20,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "client_ip": "172.18.0.1"
}
```

### Load Distribution (observed):
```
     20 backend-1
      0 backend-2
      0 backend-3
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Look at the load balancing algorithm being used in the upstream block. What does `ip_hash` do? How does it decide which backend to use?
</details>

<details>
<summary>Hint 2</summary>
`ip_hash` routes all requests from the same client IP to the same backend. When all your test requests come from the same machine (same IP), they ALL go to one backend. This is the same problem as a corporate NAT — thousands of users behind one IP.
</details>

<details>
<summary>Hint 3</summary>
Consider switching to `least_conn` (sends to backend with fewest active connections) or removing `ip_hash` entirely to use the default round-robin. If you need session persistence, consider using a cookie-based approach instead.
</details>

---

## 🛠️ Useful Commands

```bash
# Quick distribution test
for i in {1..30}; do curl -s http://localhost:8085/ | jq -r '.server_id'; done | sort | uniq -c

# Check backend request counts
docker-compose logs backend1 | wc -l
docker-compose logs backend2 | wc -l
docker-compose logs backend3 | wc -l

# View upstream config
docker exec lab-05-uneven-load-distribution-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
