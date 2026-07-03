# 💥 Chaos Engineering Troubleshooting Labs

## 10 Real-World Chaos Experiments

---

## 📚 What is Chaos Engineering?

Chaos Engineering = **Intentionally breaking things to find weaknesses BEFORE they cause outages.**

Netflix invented it (Chaos Monkey, 2011). Now every large company does it.

### The Process:
1. **Define steady state** (what "normal" looks like)
2. **Hypothesize** ("if we kill a pod, the service should recover in <30s")
3. **Inject failure** (kill pod, add latency, fill disk)
4. **Observe** (did alerts fire? did it recover? how long?)
5. **Fix** the weaknesses you found

---

## 🏗️ Chaos Tools

```
┌─────────────────────────────────────────────────┐
│             Chaos Experiments                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │   Pod    │  │ Network  │  │   Resource   │  │
│  │  Chaos   │  │  Chaos   │  │   Chaos      │  │
│  │          │  │          │  │              │  │
│  │ Kill pod │  │ Partition│  │ CPU stress   │  │
│  │ Restart  │  │ Latency  │  │ Memory hog   │  │
│  │ Drain    │  │ DNS fail │  │ Disk fill    │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│                                                  │
│  Tools: Litmus Chaos | Chaos Mesh | Gremlin     │
└─────────────────────────────────────────────────┘
```

---

## 📋 Labs

| # | Lab | Difficulty | Experiment | What You Validate |
|---|-----|-----------|-----------|-------------------|
| 01 | Pod Kill Recovery | ⭐ Easy | Delete random pods | Auto-healing, PDB |
| 02 | Network Partition | ⭐⭐ Medium | Block traffic between services | Circuit breaker, retry |
| 03 | CPU Stress | ⭐⭐ Medium | Consume all CPU | HPA scaling, alerts |
| 04 | Memory Pressure | ⭐⭐ Medium | OOM scenarios | Limits, OOM killer |
| 05 | Disk Fill | ⭐⭐ Medium | Fill persistent volume | Alerting, cleanup |
| 06 | DNS Failure | ⭐⭐⭐ Hard | Break DNS resolution | Caching, retries |
| 07 | Latency Injection | ⭐⭐⭐ Hard | Add 5s delay | Timeouts, SLOs |
| 08 | Node Drain | ⭐⭐ Medium | Drain a K8s node | PDB, rescheduling |
| 09 | Dependency Unavailable | ⭐⭐⭐ Hard | Kill downstream service | Fallbacks, graceful degradation |
| 10 | Zone Failure | ⭐⭐⭐⭐ Expert | Simulate AZ outage | Multi-AZ resilience |

---

## 📖 Reference
- Principles: https://principlesofchaos.org/
- Litmus: https://litmuschaos.io/
- Chaos Mesh: https://chaos-mesh.org/
