# 🔧 Cilium Troubleshooting Labs

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
| 01 | [lab-01-cilium-agent-not-ready](lab-01-cilium-agent-not-ready/) | ⭐⭐ Medium |
| 02 | [lab-02-network-policy-not-enforcing](lab-02-network-policy-not-enforcing/) | ⭐⭐ Medium |
| 03 | [lab-03-service-mesh-broken](lab-03-service-mesh-broken/) | ⭐⭐ Medium |
| 04 | [lab-04-hubble-not-observing](lab-04-hubble-not-observing/) | ⭐⭐ Medium |
| 05 | [lab-05-egress-gateway-failing](lab-05-egress-gateway-failing/) | ⭐⭐ Medium |
| 06 | [lab-06-cluster-mesh-disconnected](lab-06-cluster-mesh-disconnected/) | ⭐⭐ Medium |
| 07 | [lab-07-bandwidth-limit-not-applied](lab-07-bandwidth-limit-not-applied/) | ⭐⭐ Medium |
| 08 | [lab-08-host-firewall-blocking](lab-08-host-firewall-blocking/) | ⭐⭐ Medium |
| 09 | [lab-09-identity-allocation-failed](lab-09-identity-allocation-failed/) | ⭐⭐ Medium |
| 10 | [lab-10-bgp-peering-down](lab-10-bgp-peering-down/) | ⭐⭐ Medium |

---

## Prerequisites
- Docker installed
- kubectl configured (for K8s-related labs)
- Relevant CLI tools installed
