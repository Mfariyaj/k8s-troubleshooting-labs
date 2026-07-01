# ☸️ Kubernetes Troubleshooting Labs

## 15 Real-World Broken Deployments

---

## Overview

These labs contain intentionally broken Kubernetes YAML deployments. Each lab creates its own namespace and deploys a broken workload that you must diagnose and fix using `kubectl` CLI.

---

## Labs

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 01 | [CrashLoopBackOff](lab-01-crashloopbackoff/) | ⭐ Beginner | Pod crashing due to wrong command |
| 02 | [ImagePullBackOff](lab-02-imagepullbackoff/) | ⭐ Beginner | Wrong image name/tag |
| 03 | [Pending Pod](lab-03-pending-pod/) | ⭐ Beginner | Impossible resource requests |
| 04 | [Service Selector Mismatch](lab-04-service-selector-mismatch/) | ⭐⭐ Intermediate | Service can't find pods (no endpoints) |
| 05 | [ConfigMap Mount](lab-05-configmap-mount/) | ⭐⭐ Intermediate | Wrong ConfigMap reference |
| 06 | [Missing Secret](lab-06-missing-secret/) | ⭐⭐ Intermediate | Pod references non-existent Secret |
| 07 | [Liveness Probe](lab-07-liveness-probe/) | ⭐⭐ Intermediate | Wrong probe port/path causing restarts |
| 08 | [PVC StorageClass](lab-08-pvc-storageclass/) | ⭐⭐ Intermediate | PVC stuck pending (wrong StorageClass) |
| 09 | [NetworkPolicy](lab-09-networkpolicy/) | ⭐⭐⭐ Advanced | Policy blocking frontend→backend traffic |
| 10 | [RBAC](lab-10-rbac/) | ⭐⭐⭐ Advanced | ServiceAccount permission denied |
| 11 | [Init Container](lab-11-init-container/) | ⭐⭐⭐ Advanced | Init container stuck/failing |
| 12 | [Node Affinity](lab-12-node-affinity/) | ⭐⭐⭐ Advanced | No nodes match affinity rules |
| 13 | [HPA Metrics](lab-13-hpa-metrics/) | ⭐⭐⭐ Advanced | HPA can't scale (missing metrics-server) |
| 14 | [DNS Failure](lab-14-dns-failure/) | ⭐⭐⭐⭐ Expert | dnsPolicy: None breaks resolution |
| 15 | [Rolling Update](lab-15-rolling-update/) | ⭐⭐⭐⭐ Expert | Update stuck (readiness probe failing) |

---

## Quick Start

### Deploy a single lab:
```bash
cd lab-01-crashloopbackoff
./deploy.sh
```

### Deploy all labs:
```bash
./deploy-all.sh
```

### Clean up all labs:
```bash
./cleanup.sh
```

---

## Prerequisites

- `kubectl` configured and connected to a cluster
- A running K8s cluster (minikube, kind, k3s, or EKS)

---

## Troubleshooting Commands

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl get endpoints -n <namespace>
kubectl get pvc -n <namespace>
kubectl auth can-i --list --as=system:serviceaccount:<ns>:<sa> -n <namespace>
```
