# 🐳 Docker Troubleshooting Labs

## 10 Real-World Broken Docker Environments for DevOps Engineers

These labs contain **intentionally broken** Docker configurations. Your job is to diagnose and fix each issue using Docker CLI commands, logs, and your knowledge of container internals.

---

## 🚀 How To Use These Labs (Step-by-Step)



1. `cd lab-01-dockerfile-build-failure && ./deploy.sh`

2. Observe the Docker build/run error

3. Check `docker logs`, `docker ps`, `docker inspect`

4. Fix the Dockerfile or docker-compose.yml

5. Rebuild and verify: `docker-compose up --build`

6. Cleanup: `./cleanup.sh`



---

## Prerequisites
- Docker Engine 20.10+ installed
- Docker Compose v2 installed
- Basic to advanced Docker knowledge
- ~2GB free disk space for images

---

## Lab Index

| # | Lab | Scenario | Difficulty |
|---|-----|----------|------------|
| 01 | [Dockerfile Build Failure](lab-01-dockerfile-build-failure/) | Multi-line RUN syntax errors, wrong base image | ⭐ |
| 02 | [Layer Caching Broken](lab-02-layer-caching-broken/) | Build takes forever, cache invalidated every time | ⭐ |
| 03 | [Container Networking](lab-03-container-networking/) | Microservices can't communicate | ⭐⭐ |
| 04 | [Volume Permissions](lab-04-volume-permissions/) | Permission denied on mounted volumes | ⭐⭐ |
| 05 | [Multi-stage Build](lab-05-multistage-build/) | Runtime binary crashes with 'not found' | ⭐⭐ |
| 06 | [Depends_on Race](lab-06-depends-on-race/) | App crashes because DB isn't ready | ⭐⭐⭐ |
| 07 | [Healthcheck Failing](lab-07-healthcheck-failing/) | Container always marked unhealthy | ⭐⭐⭐ |
| 08 | [OOM Killed](lab-08-oom-killed/) | Container keeps getting killed | ⭐⭐⭐ |
| 09 | [Entrypoint vs CMD](lab-09-entrypoint-cmd/) | Container ignores runtime arguments | ⭐⭐⭐ |
| 10 | [Registry Auth](lab-10-registry-auth/) | Can't pull images from private registry | ⭐⭐⭐⭐ |

---

## How to Use

### Deploy a single lab:
```bash
cd lab-01-dockerfile-build-failure
./deploy.sh
```

### Deploy ALL labs at once:
```bash
./deploy.sh
```

### Clean up ALL labs:
```bash
./cleanup.sh
```

---

## Tips
- Start with the easier labs (01-02) as warm-up
- Read the README in each lab folder for hints
- Use `docker logs`, `docker inspect`, `docker events`, and `docker stats` as your primary tools
- Think like a detective - follow the error messages!

---

## Rules
1. **Don't look at the fix** before trying to diagnose (that's cheating!)
2. Deploy the lab → investigate using Docker CLI → identify the issue → fix it
3. Time yourself - an experienced DevOps engineer should solve most in under 10 minutes

Good luck! 🚀
