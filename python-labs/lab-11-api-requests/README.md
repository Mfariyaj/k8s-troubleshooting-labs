# Lab 11: API Requests — HTTP Calls, Auth, and Error Handling

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-11/broken_script.py
cd /tmp/python-lab-11 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Making HTTP API Calls in Python**

DevOps engineers constantly interact with REST APIs — Kubernetes, GitHub, Prometheus, cloud providers. Key concepts:

- **Always set a timeout** — without it, a network issue causes your script to hang forever
- **Check status codes before parsing** — a 401/403/500 response may not contain valid JSON or the data you expect
- **Auth header format matters** — GitHub wants `Bearer TOKEN`, K8s might want different formats
- **response.json() can fail** — if the body isn't valid JSON, you get `json.JSONDecodeError`
- **Retry with backoff** — network calls fail transiently; retrying after 1-2-4 seconds helps

Common status codes:
- 200: OK (success)
- 401: Unauthorized (bad/missing auth token)
- 403: Forbidden (valid auth, no permission)
- 404: Not Found
- 429: Rate Limited (too many requests)
- 500/503: Server Error

This lab uses simulated responses so it works offline.

---

## 🔧 Scenario

A monitoring dashboard script that queries Prometheus for metrics, GitHub for branch info, and Kubernetes for cluster version. The script has authentication and response handling bugs.

---

## 💥 Error Output

The script runs but produces incorrect results:
- GitHub API shows an auth error because the token format is wrong
- The status code isn't checked, so error responses get parsed as if they were successful

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Look at the GitHub Authorization header. API tokens typically need a prefix like "Bearer" or "token". Just passing the bare token string won't authenticate.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three issues:
1. `get_prometheus_metrics()`: No timeout parameter — should always set a timeout
2. `get_github_branches()`: Auth header should be `f"token {token}"` not just `token`
3. `get_github_branches()`: Not checking `response.status_code` — if it's 401, the response contains an error message, not branch data
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Add `timeout=10` to the simulate_api_call in get_prometheus_metrics
2. Change headers to: `"Authorization": f"token {token}"`
3. After the API call, check: `if response.status_code != 200: raise Exception(f"API returned {response.status_code}: {response.text}")`
</details>

---

## 📖 Python Docs Reference

- [urllib.request](https://docs.python.org/3/library/urllib.request.html)
- [json module](https://docs.python.org/3/library/json.html)
- [HTTP Status Codes (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [requests library (third-party)](https://requests.readthedocs.io/en/latest/)

---

## Difficulty: ⭐⭐⭐ Advanced

**Expected time:** 7-10 minutes  
**Bugs to find:** 3  
**Concept:** HTTP API interaction, auth headers, response validation
