# 🐧 Linux/Networking Troubleshooting Labs

## 10 Real-World Broken Scenarios for Linux & Networking

---

## Overview

These labs simulate common Linux system administration and networking failures you'll encounter in production. Each lab creates a **safely broken** environment that you must diagnose and fix using only CLI tools.

**⚠️ Safety Note:** All labs are designed to be non-destructive. Disk operations use `/tmp`, network changes are reversible, and cleanup scripts restore original state.

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 01 | [Disk Full](lab-01-disk-full/) | 🟢 Easy | Filesystem at 100% due to deleted-but-open files |
| 02 | [Zombie Processes](lab-02-zombie-processes/) | 🟢 Easy | Zombie processes accumulating on the system |
| 03 | [Firewall Blocking](lab-03-firewall-blocking/) | 🟡 Medium | Application running but unreachable due to iptables |
| 04 | [DNS Resolution](lab-04-dns-resolution/) | 🟡 Medium | DNS resolution failing due to corrupted resolv.conf |
| 05 | [File Permissions](lab-05-file-permissions/) | 🟢 Easy | Application failing due to incorrect file permissions |
| 06 | [Memory Leak / OOM](lab-06-memory-leak-oom/) | 🟡 Medium | Process killed by OOM killer due to memory leak |
| 07 | [Cron Not Running](lab-07-cron-not-running/) | 🟡 Medium | Cron jobs silently failing due to multiple issues |
| 08 | [Swap Thrashing](lab-08-swap-thrashing/) | 🔴 Hard | System thrashing due to excessive swap usage |
| 09 | [TCP Port Exhaustion](lab-09-tcp-port-exhaustion/) | 🔴 Hard | Ephemeral port exhaustion causing connection failures |
| 10 | [Systemd Service Failure](lab-10-systemd-service-failure/) | 🔴 Hard | Service failing to start with multiple systemd issues |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-disk-full
sudo bash deploy.sh
```

### Deploy all labs:
```bash
sudo bash deploy-all.sh
```

### Clean up a single lab:
```bash
cd lab-01-disk-full
sudo bash cleanup.sh
```

### Clean up all labs:
```bash
sudo bash cleanup-all.sh
```

---

## 📋 Prerequisites

| Tool | Required |
|------|----------|
| Linux system (Ubuntu/Debian/RHEL) | ✅ |
| Root/sudo access | ✅ |
| `lsof`, `ss`, `dig`, `curl` | ✅ |
| `iptables` | Labs 03 |
| `python3` | Labs 03, 06, 09 |
| `systemd` | Lab 10 |
| `cron` | Lab 07 |

---

## ⚔️ Rules of Engagement

1. Deploy the lab → investigate using only CLI tools → identify root cause → fix it
2. Don't read the deploy.sh before attempting diagnosis
3. Time yourself — target under 10 minutes per lab
4. Use the hints only if stuck for more than 5 minutes

---

## 📊 Progress Tracker

| Lab | Status | Time |
|-----|--------|------|
| ☐ Lab 01 - Disk Full | | |
| ☐ Lab 02 - Zombie Processes | | |
| ☐ Lab 03 - Firewall Blocking | | |
| ☐ Lab 04 - DNS Resolution | | |
| ☐ Lab 05 - File Permissions | | |
| ☐ Lab 06 - Memory Leak / OOM | | |
| ☐ Lab 07 - Cron Not Running | | |
| ☐ Lab 08 - Swap Thrashing | | |
| ☐ Lab 09 - TCP Port Exhaustion | | |
| ☐ Lab 10 - Systemd Service Failure | | |

---

Good luck, and happy troubleshooting! 🚀
