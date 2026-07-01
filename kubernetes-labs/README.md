# ☸️ Kubernetes & Istio Troubleshooting Labs

## 35 Real-World Broken Deployments (K8s Core + Istio Service Mesh)

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
| 16 | [Admission Webhook Rejection](lab-16-admission-webhook-rejection/) | ⭐⭐⭐⭐⭐ Expert | Webhook blocking all pod creates |
| 17 | [Pod Disruption Budget](lab-17-pod-disruption-budget/) | ⭐⭐⭐⭐⭐ Expert | PDB blocking node drain |
| 18 | [Sidecar Injection Failure](lab-18-sidecar-injection-failure/) | ⭐⭐⭐⭐⭐ Expert | Istio-style sidecar CrashLoopBackOff |
| 19 | [CRD Validation Failure](lab-19-crd-validation-failure/) | ⭐⭐⭐⭐⭐ Expert | Custom Resource schema rejection |
| 20 | [ETCD Quota Exceeded](lab-20-etcd-quota-exceeded/) | ⭐⭐⭐⭐⭐ Expert | etcd database space exceeded |

### 🌐 Istio Service Mesh Labs

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 21 | [Istio Sidecar Not Injecting](lab-21-istio-sidecar-not-injecting/) | ⭐⭐⭐ Advanced | Sidecar injection disabled/missing |
| 22 | [VirtualService Routing](lab-22-istio-virtualservice-routing/) | ⭐⭐⭐ Advanced | Traffic goes to wrong service version |
| 23 | [Canary Deployment](lab-23-istio-canary-deployment/) | ⭐⭐⭐ Advanced | 90/10 weight split not working |
| 24 | [Blue-Green Deployment](lab-24-istio-blue-green/) | ⭐⭐⭐ Advanced | Can't switch traffic from blue to green |
| 25 | [Circuit Breaker](lab-25-istio-circuit-breaker/) | ⭐⭐⭐⭐ Expert | outlierDetection not ejecting bad pods |
| 26 | [mTLS Strict Mode](lab-26-istio-mtls-strict/) | ⭐⭐⭐⭐ Expert | STRICT mTLS breaking non-mesh services |
| 27 | [Gateway TLS](lab-27-istio-gateway-tls/) | ⭐⭐⭐⭐ Expert | TLS termination 503 errors |
| 28 | [Timeout & Retry](lab-28-istio-timeout-retry/) | ⭐⭐⭐⭐ Expert | Retries amplifying load, timeout conflicts |
| 29 | [Fault Injection](lab-29-istio-fault-injection/) | ⭐⭐⭐ Advanced | Chaos faults not being injected |
| 30 | [Authorization Policy](lab-30-istio-authorization-policy/) | ⭐⭐⭐⭐ Expert | DENY rules blocking legitimate traffic |
| 31 | [Rate Limiting](lab-31-istio-rate-limiting/) | ⭐⭐⭐⭐⭐ Expert | EnvoyFilter rate limit not working |
| 32 | [Traffic Mirroring](lab-32-istio-traffic-mirroring/) | ⭐⭐⭐ Advanced | Shadow traffic not reaching canary |
| 33 | [ServiceEntry External](lab-33-istio-service-entry/) | ⭐⭐⭐⭐ Expert | Can't reach external APIs from mesh |
| 34 | [Multi-Cluster](lab-34-istio-multicluster-connectivity/) | ⭐⭐⭐⭐⭐ Expert | Cross-cluster service discovery broken |
| 35 | [Observability Broken](lab-35-istio-observability-broken/) | ⭐⭐⭐⭐⭐ Expert | Kiali/Jaeger/metrics not working |

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
- **Istio installed** (for labs 21-35): `istioctl install --set profile=demo`

---

## Troubleshooting Commands

```bash
# Kubernetes
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl get endpoints -n <namespace>
kubectl get pvc -n <namespace>
kubectl auth can-i --list --as=system:serviceaccount:<ns>:<sa> -n <namespace>

# Istio
istioctl analyze -n <namespace>
istioctl proxy-config routes <pod-name> -n <namespace>
istioctl proxy-config clusters <pod-name> -n <namespace>
istioctl proxy-config endpoints <pod-name> -n <namespace>
istioctl proxy-status
kubectl get virtualservices,destinationrules,gateways -n <namespace>
kubectl logs <pod-name> -c istio-proxy -n <namespace>
```
