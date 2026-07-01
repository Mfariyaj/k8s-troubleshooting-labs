# Lab 09: Infinite Redirect Loop

## 🎯 Scenario

Your Nginx is configured to redirect HTTP to HTTPS, and your backend application also enforces HTTPS. Users report that the site is completely broken — browsers show **"This page isn't working - redirected you too many times"** (ERR_TOO_MANY_REDIRECTS). The redirect loop is infinite.

**Difficulty:** ⭐⭐ Medium

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Port 8089 - Nginx HTTP → always redirects to HTTPS
curl -vL http://localhost:8089/
# Shows: 301 → https://localhost/ → connection refused (no HTTPS listener)

# Port 8090 - Nginx passes to app, but app also redirects
curl -vL --max-redirs 5 http://localhost:8090/
# Shows: 301 → 301 → 301 → 301 → 301 → "Maximum redirects followed"
```

### curl -vL Output:
```
* Following redirect to https://localhost:8090/
* Could not resolve host: localhost
* Closing connection
curl: (47) Maximum (5) redirects followed

-- OR with the backend port --

< HTTP/1.1 301 Moved Permanently
< Location: https://localhost/
< 
* Issue another request to this URL: 'https://localhost/'
* Connection refused
```

### Docker Logs (app):
```
[REDIRECT] Redirecting to HTTPS (proto detected: http)
[REDIRECT] Redirecting to HTTPS (proto detected: http)
[REDIRECT] Redirecting to HTTPS (proto detected: http)
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
There are TWO redirects happening: Nginx redirects HTTP→HTTPS on port 80, AND the backend app redirects to HTTPS because it doesn't know the original request was already HTTPS (after TLS termination).
</details>

<details>
<summary>Hint 2</summary>
The app checks `X-Forwarded-Proto` to determine if the original connection was HTTPS. Nginx is NOT setting this header, so the app always thinks the connection is plain HTTP.
</details>

<details>
<summary>Hint 3</summary>
Fix: Add `proxy_set_header X-Forwarded-Proto $scheme;` (or `https` if TLS is terminated before Nginx) to the proxy location block. This tells the app "the client's original connection was HTTPS" so it stops redirecting. Also, don't have both Nginx AND the app doing the HTTP→HTTPS redirect.
</details>

---

## 🛠️ Useful Commands

```bash
# See redirect chain (limited to 5 redirects)
curl -vL --max-redirs 5 http://localhost:8090/ 2>&1 | grep -E "(Location:|HTTP/)"

# Single request without following redirects
curl -sI http://localhost:8090/

# Check what headers the app receives
docker-compose logs app

# Test if app works when X-Forwarded-Proto is set manually
curl -s -H "X-Forwarded-Proto: https" http://localhost:8090/ | jq .
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
