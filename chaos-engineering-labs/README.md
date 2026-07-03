# 🔧 Chaos Engineering Troubleshooting Labs

## 10 Real-World Broken Scenarios

---

## 🚀 How To Use These Labs

1. `cd lab-01-* && ./deploy.sh`
2. Observe the error output
3. Diagnose and fix the issue
4. Verify your fix works
5. `./cleanup.sh` when done

---

## 📋 Labs

| # | Lab | Difficulty |
|---|-----|-----------|
| 01 | [lab-01-pod-kill-recovery](lab-01-pod-kill-recovery/) | ⭐⭐ Medium |
| 02 | [lab-02-network-partition](lab-02-network-partition/) | ⭐⭐ Medium |
| 03 | [lab-03-cpu-stress-test](lab-03-cpu-stress-test/) | ⭐⭐ Medium |
| 04 | [lab-04-memory-pressure](lab-04-memory-pressure/) | ⭐⭐ Medium |
| 05 | [lab-05-disk-fill-attack](lab-05-disk-fill-attack/) | ⭐⭐ Medium |
| 06 | [lab-06-dns-failure-injection](lab-06-dns-failure-injection/) | ⭐⭐ Medium |
| 07 | [lab-07-latency-injection](lab-07-latency-injection/) | ⭐⭐ Medium |
| 08 | [lab-08-node-drain-chaos](lab-08-node-drain-chaos/) | ⭐⭐ Medium |
| 09 | [lab-09-dependency-unavailable](lab-09-dependency-unavailable/) | ⭐⭐ Medium |
| 10 | [lab-10-zone-failure](lab-10-zone-failure/) | ⭐⭐ Medium |

---

## Prerequisites
- Docker installed
- kubectl configured (for K8s-related labs)
- Relevant CLI tools installed
