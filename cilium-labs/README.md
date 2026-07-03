# 🐝 Cilium Troubleshooting Labs

## 10 Real-World eBPF Networking Scenarios

---

## 📚 What is Cilium?

Cilium is a **Kubernetes CNI plugin** powered by **eBPF** (extended Berkeley Packet Filter). It replaces iptables with programmable kernel-level networking.

### Why Cilium is the Future:
- **10x faster** than iptables for large clusters
- **L7 policies** — filter HTTP methods, gRPC services, Kafka topics
- **Service mesh** without sidecars (runs in kernel)
- **Hubble** — real-time network flow observability

### Architecture:
```
┌──────────────────────────────────────────┐
│           Kubernetes Node                 │
│                                          │
│  ┌──────┐  ┌──────┐  ┌──────┐          │
│  │ Pod A│  │ Pod B│  │ Pod C│          │
│  └──┬───┘  └──┬───┘  └──┬───┘          │
│     │         │         │               │
│  ┌──▼─────────▼─────────▼──┐           │
│  │     Cilium Agent (eBPF)  │           │
│  │  ┌─────────────────────┐ │           │
│  │  │  eBPF Programs       │ │           │
│  │  │  (in Linux kernel)   │ │           │
│  │  │  - Network policy    │ │           │
│  │  │  - Load balancing    │ │           │
│  │  │  - Encryption        │ │           │
│  │  │  - Observability     │ │           │
│  │  └─────────────────────┘ │           │
│  └──────────────────────────┘           │
│                                          │
│  ┌──────────────────────────┐           │
│  │  Hubble (flow logs)      │           │
│  └──────────────────────────┘           │
└──────────────────────────────────────────┘
```

---

## 📋 Labs

| # | Lab | Difficulty | What Breaks |
|---|-----|-----------|-------------|
| 01 | Agent Not Ready | ⭐ Easy | CNI config wrong |
| 02 | Policy Not Enforcing | ⭐⭐ Medium | CiliumNetworkPolicy syntax |
| 03 | Service Mesh Broken | ⭐⭐⭐ Hard | mTLS configuration |
| 04 | Hubble Not Observing | ⭐⭐ Medium | Relay not connected |
| 05 | Egress Gateway | ⭐⭐⭐ Hard | NAT policy wrong |
| 06 | Cluster Mesh | ⭐⭐⭐⭐ Expert | Multi-cluster discovery |
| 07 | Bandwidth Limit | ⭐⭐ Medium | Annotation not applied |
| 08 | Host Firewall | ⭐⭐⭐ Hard | Host-level rules blocking |
| 09 | Identity Allocation | ⭐⭐⭐ Hard | Kvstore unreachable |
| 10 | BGP Peering | ⭐⭐⭐⭐ Expert | External router config |

---

## 📖 Reference
- Docs: https://docs.cilium.io/
- Hubble: https://docs.cilium.io/en/stable/observability/hubble/
