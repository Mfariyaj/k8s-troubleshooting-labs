## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 12: HTTP/2 Stream Multiplexing Issues

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your application uses Nginx as a reverse proxy with HTTP/2 enabled for frontend connections. Under moderate load (50+ concurrent users), clients experience:
- Connections being abruptly terminated with GOAWAY frames
- Fast requests being blocked behind slow requests (head-of-line blocking)
- HTTP/2 stream resets (RST_STREAM) during normal operation
- gRPC streaming calls timing out after 5 seconds

The application works perfectly with a single user but degrades rapidly under concurrency. The operations team suspects an Nginx misconfiguration but `nginx -t` passes without errors.

## Architecture

```
Clients (HTTP/2) → Nginx (SSL + HTTP/2 termination) → Backend (HTTP/1.1 on port 3000)
                                                    → gRPC Backend (port 50051)
```

## What You'll Observe

### nginx -t output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Single request (works):
```bash
$ curl -k --http2 https://localhost:8443/fast
{"endpoint":"fast","reqId":1,"timestamp":1710500000000}
```

### Concurrent requests (GOAWAY storms):
```bash
$ for i in $(seq 1 10); do curl -k --http2 https://localhost:8443/slow & done
curl: (92) HTTP/2 stream 0 was not closed cleanly: ENHANCE_YOUR_CALM (error 11)
curl: (16) Error in the HTTP2 framing layer
curl: (92) HTTP/2 stream 1 was not closed cleanly: REFUSED_STREAM (error 7)
```

### nghttp verbose output:
```bash
$ nghttp -nv https://localhost:8443/fast
[  0.023] recv SETTINGS frame
          (niv=1)
          [MAX_CONCURRENT_STREAMS(0x03):1]     <-- BUG: Only 1 stream allowed!
[  0.045] recv GOAWAY frame
          (last_stream_id=1, error_code=NO_ERROR(0x00))
```

### Nginx error.log:
```
2024/03/15 14:30:22 [error] 8#8: *154 upstream timed out (110: Connection timed out) while connecting to upstream
2024/03/15 14:30:22 [warn] 8#8: *155 keepalive_requests limit exceeded, closing connection
2024/03/15 14:30:23 [error] 8#8: *156 client sent too large header while processing HTTP/2 connection
```

## Hints

<details>
<summary>Hint 1</summary>
HTTP/2's key advantage is multiplexing many streams over a single connection. If `http2_max_concurrent_streams` is set to 1, you've effectively disabled multiplexing. The server will send GOAWAY after each request, forcing new connections. Check what value makes sense for a production setup (128-256 is typical).
</details>

<details>
<summary>Hint 2</summary>
The proxy layer uses `proxy_http_version 1.1` which means all multiplexed HTTP/2 streams from clients must be serialized onto HTTP/1.1 connections to the backend. This causes head-of-line blocking: a slow `/slow` request blocks subsequent `/fast` requests on the same backend connection. Consider enabling keepalive connections to the upstream with a pool.
</details>

<details>
<summary>Hint 3</summary>
`keepalive_requests 100` limits total requests per connection. HTTP/2 clients send all requests over one connection, so 100 requests = GOAWAY after the 100th. HTTP/2 setups need much higher values (10000+). Also, `large_client_header_buffers 2 1k` is too small — HTTP/2 HPACK can decompress to larger header sizes.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Test single HTTP/2 request
curl -k --http2 https://localhost:8443/fast

# Test with verbose HTTP/2 frames (requires nghttp2)
nghttp -nv https://localhost:8443/fast

# Concurrent load test
for i in $(seq 1 20); do curl -sk --http2 https://localhost:8443/slow & done; wait

# Mix fast and slow requests (observe HOL blocking)
curl -sk --http2 https://localhost:8443/slow & curl -sk --http2 https://localhost:8443/fast &

# Check connection reuse with curl
curl -k --http2 -w "conn_id:%{connection_id} http_code:%{http_code}\n" https://localhost:8443/fast https://localhost:8443/fast

# Watch Nginx error logs
docker exec http2-nginx tail -f /var/log/nginx/error.log

# Monitor active connections
docker exec http2-nginx cat /proc/net/tcp | wc -l

# Check Nginx stub_status
curl -sk --http2 https://localhost:8443/nginx_status

# Backend request stats
docker exec http2-backend curl -s http://localhost:3000/health

# Test streaming endpoint
curl -k --http2 -N https://localhost:8443/streaming

# Test gRPC timeout (if grpcurl installed)
# grpcurl -insecure localhost:8443 grpc.health.v1.Health/Check

# Check HTTP/2 settings advertised by server
curl -k --http2 -v https://localhost:8443/ 2>&1 | grep -i "h2\|http2\|settings"

# Inspect GOAWAY behavior
h2load -n 200 -c 1 -m 10 https://localhost:8443/fast 2>&1 | tail -20

# Clean up
./cleanup.sh
```

## Root Causes

There are **5 compounding issues** in this lab:

1. **http2_max_concurrent_streams=1** — Only allows 1 active stream per connection, defeating HTTP/2 multiplexing entirely
2. **keepalive_requests=100** — Too low for HTTP/2 where all requests share one connection; triggers GOAWAY after 100 requests
3. **proxy_http_version 1.1** — Backend connections don't support HTTP/2, causing head-of-line blocking at the proxy layer
4. **grpc_send_timeout=5s** — Too low for streaming gRPC calls, causing premature stream termination
5. **large_client_header_buffers 2 1k** — Too small for HTTP/2 HPACK decompressed headers, causing "too large header" errors
