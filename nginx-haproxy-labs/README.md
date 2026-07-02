# 🌐 Nginx/HAProxy Troubleshooting Labs


## 🚀 How To Use These Labs



### Prerequisites:

- Docker & Docker Compose installed

- `curl` for testing

- Ports 8081-8091 available (each lab uses unique port)



### Steps:

1. `cd lab-01-502-bad-gateway && ./deploy.sh`

2. Test: `curl -v http://localhost:8081/`

3. Check logs: `docker logs <nginx-container>`

4. Validate: `docker exec <container> nginx -t`

5. Fix nginx.conf and restart

6. Cleanup: `./cleanup.sh`



---


## 10 Real-World Broken Scenarios for Nginx & Reverse Proxy Engineers

---

## Overview

These labs simulate common Nginx reverse proxy misconfigurations that cause real production incidents. Each lab contains a broken Nginx configuration paired with a backend application running in Docker containers. Your job is to diagnose and fix the issue using only CLI tools.

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 01 | [502 Bad Gateway](lab-01-502-bad-gateway/) | ⭐ Easy | Upstream backend port mismatch |
| 02 | [SSL Certificate Errors](lab-02-ssl-certificate-errors/) | ⭐⭐ Medium | Mismatched certificate and private key |
| 03 | [Rate Limiting](lab-03-rate-limiting/) | ⭐⭐ Medium | Overly aggressive rate limiting blocking health checks |
| 04 | [Proxy Headers Missing](lab-04-proxy-headers-missing/) | ⭐⭐ Medium | Missing proxy headers causing app misbehavior |
| 05 | [Uneven Load Distribution](lab-05-uneven-load-distribution/) | ⭐⭐⭐ Hard | ip_hash with NAT causing all traffic to one backend |
| 06 | [WebSocket Timeout](lab-06-websocket-timeout/) | ⭐⭐⭐ Hard | WebSocket connections failing due to missing upgrade headers |
| 07 | [Location Block Priority](lab-07-location-block-priority/) | ⭐⭐ Medium | Conflicting location blocks with wrong priority |
| 08 | [Proxy Cache Stale](lab-08-proxy-cache-stale/) | ⭐⭐⭐ Hard | Cache key missing user identifier causing data leaks |
| 09 | [Infinite Redirect](lab-09-infinite-redirect/) | ⭐⭐ Medium | Nginx + app both redirecting causing infinite loop |
| 10 | [Connection Timeouts](lab-10-connection-timeouts/) | ⭐⭐⭐ Hard | Worker connections exhaustion under load |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-502-bad-gateway
./deploy.sh
```

### Deploy all labs:
```bash
./deploy-all.sh
```

### Clean up a single lab:
```bash
cd lab-01-502-bad-gateway
./cleanup.sh
```

### Clean up all labs:
```bash
./cleanup-all.sh
```

---

## 📋 Prerequisites

| Tool | Purpose |
|------|---------|
| `docker` | Container runtime |
| `docker-compose` | Multi-container orchestration |
| `curl` | HTTP testing |
| `openssl` | SSL/TLS debugging |
| `ab` (optional) | Apache Bench for load testing |

---

## 🔍 Useful Debugging Commands

```bash
# Check nginx config syntax
docker exec <container> nginx -t

# View nginx error logs
docker exec <container> tail -f /var/log/nginx/error.log

# Test HTTP response
curl -vvv http://localhost:8080

# Test SSL
openssl s_client -connect localhost:443

# View container logs
docker-compose logs -f

# Check upstream connectivity
docker exec <nginx-container> curl http://backend:3000
```

---

## ⚔️ Rules of Engagement

1. Deploy the lab with `./deploy.sh`
2. Observe the failure using `curl`, `docker logs`, `nginx -t`
3. Diagnose the root cause
4. Fix the nginx.conf or docker-compose.yml
5. Verify the fix works
6. Clean up with `./cleanup.sh`

---

## 📊 Progress Tracker

| Lab | Status | Time |
|-----|--------|------|
| ☐ Lab 01 - 502 Bad Gateway | | |
| ☐ Lab 02 - SSL Certificate Errors | | |
| ☐ Lab 03 - Rate Limiting | | |
| ☐ Lab 04 - Proxy Headers Missing | | |
| ☐ Lab 05 - Uneven Load Distribution | | |
| ☐ Lab 06 - WebSocket Timeout | | |
| ☐ Lab 07 - Location Block Priority | | |
| ☐ Lab 08 - Proxy Cache Stale | | |
| ☐ Lab 09 - Infinite Redirect | | |
| ☐ Lab 10 - Connection Timeouts | | |

---

Good luck, and happy troubleshooting! 🚀
