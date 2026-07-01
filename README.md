# 🔧 Kubernetes Troubleshooting Labs

## 15 Real-World Broken Deployments for DevOps Engineers

These labs contain **intentionally broken** Kubernetes deployments. Your job is to diagnose and fix each issue using only `kubectl` commands in your terminal.

---

## Prerequisites
- A running Kubernetes cluster (minikube, kind, k3s, EKS, etc.)
- `kubectl` configured and connected to the cluster
- Basic to advanced Kubernetes knowledge

---

## Lab Index

| # | Lab | Scenario | Difficulty |
|---|-----|----------|------------|
| 01 | CrashLoopBackOff | Misconfigured container command | ⭐ |
| 02 | ImagePullBackOff | Wrong image name/tag | ⭐ |
| 03 | Pending Pod | Impossible resource requests | ⭐⭐ |
| 04 | Service Selector Mismatch | Service can't find pods | ⭐⭐ |
| 05 | ConfigMap Mount | Wrong ConfigMap name referenced | ⭐⭐ |
| 06 | Missing Secret | Secret never created | ⭐⭐ |
| 07 | Liveness Probe | Wrong path/port causing restarts | ⭐⭐ |
| 08 | PVC StorageClass | Non-existent StorageClass | ⭐⭐ |
| 09 | NetworkPolicy | Traffic blocked by policy | ⭐⭐⭐ |
| 10 | RBAC | Wrong ServiceAccount binding | ⭐⭐⭐ |
| 11 | Init Container | Waiting for non-existent service | ⭐⭐⭐ |
| 12 | Node Affinity | No node matches affinity rules | ⭐⭐⭐ |
| 13 | HPA Metrics | Metrics server missing/broken | ⭐⭐⭐ |
| 14 | DNS Resolution | DNS misconfiguration | ⭐⭐⭐ |
| 15 | Rolling Update | Readiness probe blocks rollout | ⭐⭐⭐⭐ |

---

## How to Use

### Deploy a single lab:
```bash
cd lab-01-crashloopbackoff
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
```

### Deploy ALL labs at once:
```bash
./deploy-all.sh
```

### Clean up ALL labs:
```bash
./cleanup.sh
```

---

## Tips
- Start with the easier labs (01-02) as warm-up
- Read the README in each lab folder for hints
- Use `kubectl describe`, `kubectl logs`, and `kubectl get events` as your primary tools
- Think like a detective - follow the error messages!

---

## Rules
1. **Don't look at the YAML** before trying to diagnose (that's cheating!)
2. Deploy the lab → investigate using only kubectl → identify the issue → fix it
3. Time yourself - a 5-year DevOps engineer should solve most in under 10 minutes

Good luck! 🚀
