# Lab 08: Proxy Cache Stale - User Data Leak

## 🎯 Scenario

You've enabled Nginx proxy caching to improve performance. However, users are reporting they can see **other users' private data** (profile info, salary, email). The caching configuration doesn't account for user identity, causing one user's cached response to be served to a completely different user.

This is a **security vulnerability** — a cache poisoning / data leak issue.

**Difficulty:** ⭐⭐⭐ Hard

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Request as Alice
curl -s -b "session=user-alice" http://localhost:8088/ | jq .

# Request as Bob (should show Bob's data, but shows Alice's cached response!)
curl -s -b "session=user-bob" http://localhost:8088/ | jq .

# Check cache status header
curl -sI -b "session=user-carol" http://localhost:8088/ | grep X-Cache
```

### curl Response (as Bob, after Alice's request was cached):
```json
{
  "profile": {
    "name": "Alice Johnson",
    "email": "alice@company.com",
    "role": "admin",
    "salary": "$150,000"
  },
  "session": "user-alice",
  "message": "Welcome back, Alice Johnson!",
  "sensitive_data": true,
  "warning": "This response contains user-specific data that should NOT be cached globally"
}
```

### X-Cache-Status Header:
```
X-Cache-Status: HIT
```
(Bob is getting Alice's cached response!)

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Look at the `proxy_cache_key` directive. What makes each cache entry unique? Does it include anything user-specific?
</details>

<details>
<summary>Hint 2</summary>
The cache key is `"$scheme$host$request_uri"` — this means the same URL always serves the same cached content regardless of who's requesting it. The cookie/session is not part of the key.
</details>

<details>
<summary>Hint 3</summary>
Solutions: (1) Add `$cookie_session` to the cache key, (2) Respect the `Cache-Control: private` header with `proxy_cache_bypass`, (3) Use `proxy_no_cache` for authenticated requests, (4) Don't cache responses that have `Vary: Cookie` header. The safest fix for user-specific data is to not cache it at all: `proxy_no_cache $cookie_session`.
</details>

---

## 🛠️ Useful Commands

```bash
# Demonstrate the data leak
echo "=== Request as Alice ==="
curl -s -b "session=user-alice" http://localhost:8088/ | jq '{name: .profile.name, cache: .session}'

echo "=== Request as Bob (shows Alice's data!) ==="
curl -s -b "session=user-bob" http://localhost:8088/ | jq '{name: .profile.name, cache: .session}'

# Check cache status
curl -sI -b "session=user-carol" http://localhost:8088/ | grep -i cache

# View nginx cache config
docker exec lab-08-proxy-cache-stale-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
