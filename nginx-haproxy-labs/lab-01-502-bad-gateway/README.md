## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 01: 502 Bad Gateway

## 🎯 Scenario

You've deployed an Nginx reverse proxy in front of a Node.js backend application. Users are reporting **502 Bad Gateway** errors when trying to access the application. The backend app appears to be running correctly when accessed directly.

**Difficulty:** ⭐ Easy

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Test the endpoint through Nginx
curl -v http://localhost:8081/

# Expected: 200 OK with JSON response
# Actual: 502 Bad Gateway
```

### Error Log Output:
```
[error] connect() failed (111: Connection refused) while connecting to upstream,
client: 172.18.0.1, server: localhost, request: "GET / HTTP/1.1",
upstream: "http://172.18.0.3:3001", host: "localhost"
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
The nginx config syntax is valid — the problem isn't a typo in directives. Look at what port Nginx is trying to connect to.
</details>

<details>
<summary>Hint 2</summary>
Check what port the backend application is actually listening on. Compare it with the upstream configuration.
</details>

<details>
<summary>Hint 3</summary>
Run `docker exec <app-container> netstat -tlnp` or check the app logs to see which port is bound.
</details>

---

## 🛠️ Useful Commands

```bash
# Check nginx config
docker exec lab-01-502-bad-gateway-nginx-1 nginx -t

# View nginx error logs
docker exec lab-01-502-bad-gateway-nginx-1 cat /var/log/nginx/error.log

# Check backend app logs
docker-compose logs app

# Test backend directly
docker exec lab-01-502-bad-gateway-nginx-1 wget -qO- http://app:3000 || echo "Failed on 3000"
docker exec lab-01-502-bad-gateway-nginx-1 wget -qO- http://app:3001 || echo "Failed on 3001"
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
