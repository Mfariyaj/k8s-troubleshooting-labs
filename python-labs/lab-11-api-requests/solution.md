# Solution: Lab 11 — API Requests

## Root Cause

### Bug 1: No timeout on Prometheus call
```python
# BROKEN: No timeout — script hangs if API is unresponsive
response = simulate_api_call(url)

# FIXED: Always specify timeout
response = simulate_api_call(url, timeout=10)
```

### Bug 2: Wrong auth header format
```python
# BROKEN: Bare token without prefix
headers = {"Authorization": token}

# FIXED: GitHub requires "token" or "Bearer" prefix
headers = {"Authorization": f"token {token}"}
```

### Bug 3: Not checking status code
```python
# BROKEN: Parses response without checking if request succeeded
response = simulate_api_call(url, headers=headers)
branches = response.json()

# FIXED: Check status code first
response = simulate_api_call(url, headers=headers)
if response.status_code != 200:
    raise Exception(f"GitHub API error {response.status_code}: {response.text}")
branches = response.json()
```

---

## Key Takeaways

1. **Always set a timeout** — `timeout=10` or appropriate value. No timeout = potential hang.
2. **Auth format varies by API** — GitHub: `token XXX`, AWS: Signature v4, K8s: `Bearer XXX`
3. **Always check status_code** — don't assume the response is what you expect
4. **response.json() can raise** — wrap in try/except for non-JSON error pages
5. **Retry transient failures** — 5xx errors and timeouts often succeed on retry
