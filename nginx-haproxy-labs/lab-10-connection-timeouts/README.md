# Lab 10: Connection Timeouts Under Load

## 🎯 Scenario

Your Nginx reverse proxy works fine for individual requests, but under even moderate load (20+ concurrent users), requests start **timing out** or getting **connection refused** errors. The backend application handles load fine when accessed directly — the bottleneck is Nginx's connection handling configuration.

**Difficulty:** ⭐⭐⭐ Hard

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Single request works fine
curl -s http://localhost:8091/ | jq .

# But under load, failures appear
./load-test.sh

# Or manually:
for i in $(seq 1 20); do
  curl -s -o /dev/null -w "Request $i: %{http_code} (%{time_total}s)\n" --max-time 10 http://localhost:8091/medium &
done
wait
```

### Error Log Output:
```
[alert] 1024 worker_connections are not enough
[error] accept() failed (24: Too many open files)
[error] *1 upstream timed out (110: Connection timed out) while connecting to upstream
```

### Load Test Results:
```
Complete requests:      100
Failed requests:        67
Non-2xx responses:      67
Requests per second:    2.31 [#/sec]
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0  1203 2045.3    0    5001
Processing:     0   412  890.2  101    5002
Total:          0  1615 2340.1  102   10003
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
Check the `worker_connections` value in the events block. This limits the total number of simultaneous connections a single worker process can handle. 10 is absurdly low for any real traffic.
</details>

<details>
<summary>Hint 2</summary>
`keepalive_timeout 0` forces Nginx to close every connection immediately after sending the response. This means every new request requires a full TCP handshake, wasting connection slots. Set it to a reasonable value (65s is common).
</details>

<details>
<summary>Hint 3</summary>
The upstream block has no `keepalive` directive. This means Nginx opens a NEW connection to the backend for every single request instead of reusing connections. Add `keepalive 32;` to the upstream block. Also increase `worker_connections` to at least 1024, and consider adding more `worker_processes`.
</details>

---

## 🛠️ Useful Commands

```bash
# Run load test
./load-test.sh

# Check nginx error log for connection issues
docker exec lab-10-connection-timeouts-nginx-1 cat /var/log/nginx/error.log

# Check active connections
docker exec lab-10-connection-timeouts-nginx-1 cat /proc/1/limits | grep "open files"

# Monitor nginx connections in real time
watch -n1 'curl -s http://localhost:8091/ > /dev/null; echo $?'

# View current config
docker exec lab-10-connection-timeouts-nginx-1 cat /etc/nginx/nginx.conf

# Check backend is healthy
docker-compose logs app | tail -20
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
