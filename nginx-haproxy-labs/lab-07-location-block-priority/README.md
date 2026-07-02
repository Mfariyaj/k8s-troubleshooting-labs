## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 07: Location Block Priority

## 🎯 Scenario

You've configured multiple Nginx location blocks to route different URL patterns to different handlers. However, requests are being routed to the **wrong handler**. Specifically:

- `/api/v1/health` should return a health check response but returns the versioned API handler
- `/api/validate` accidentally matches the versioned regex
- The priority of location blocks is not what the developer expected

**Difficulty:** ⭐⭐ Medium

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Test various paths and see which handler responds
curl -s http://localhost:8087/ | jq .
curl -s http://localhost:8087/api | jq .
curl -s http://localhost:8087/api/health | jq .
curl -s http://localhost:8087/api/v1/users | jq .
curl -s http://localhost:8087/api/v1/health | jq .
curl -s http://localhost:8087/api/validate | jq .

# Expected: /api/v1/health → health handler
# Actual:   /api/v1/health → api-versioned-regex handler
```

### curl Responses:
```bash
$ curl -s http://localhost:8087/api/v1/health
{"handler": "api-versioned-regex", "path": "/api/v1/health"}
# ❌ Expected "v1-health-prefix" or "health-exact"

$ curl -s http://localhost:8087/api/validate
{"handler": "api-versioned-regex", "path": "/api/validate"}
# ❌ Expected "api-prefix" - "validate" starts with "v" and matches v[0-9]... wait, it doesn't have a digit!
# Actually this matches because regex /api/v[0-9] matches "/api/validate" - NO! 
# Let's check: "v" followed by "a" - doesn't match [0-9]... unless the regex is broader
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
Nginx location block priority order: (1) Exact match `= /path` (highest), (2) Preferential prefix `^~ /path`, (3) Regex `~` or `~*` (first match wins), (4) Regular prefix `/path` (longest match wins). A regex match OVERRIDES a regular prefix match.
</details>

<details>
<summary>Hint 2</summary>
The regex `~ /api/v[0-9]` matches any URL containing "/api/v" followed by a digit ANYWHERE in the path. This includes /api/v1/health. Since regex takes priority over prefix matches (but not over `^~` or `=`), the prefix location `/api/v1/health` never fires.
</details>

<details>
<summary>Hint 3</summary>
Solutions: (1) Use `^~` prefix for paths that should NOT be overridden by regex, (2) Use exact match `=` where possible, (3) Add exceptions inside the regex block, (4) Restructure to use `^~ /api/v1/health` before the regex.
</details>

---

## 🛠️ Useful Commands

```bash
# Test all paths systematically
for path in / /api /api/health /api/v1/users /api/v1/health /api/v2/data /api/validate; do
  echo "$path → $(curl -s http://localhost:8087$path | jq -r '.handler')"
done

# Check nginx config
docker exec lab-07-location-block-priority-nginx-1 nginx -t

# View nginx config
docker exec lab-07-location-block-priority-nginx-1 cat /etc/nginx/nginx.conf
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
