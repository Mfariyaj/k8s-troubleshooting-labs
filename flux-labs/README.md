# 🔄 Flux CD Troubleshooting Labs

## 10 Real-World Broken GitOps Scenarios

---

## 📚 What is Flux?

Flux is a **GitOps operator for Kubernetes**. It continuously syncs your cluster state with a Git repository. If someone changes something in the cluster manually, Flux reverts it.

### How Flux Works:
```
Git Repo (source of truth)
    │
    │ Flux watches for changes
    ▼
┌─────────────────────────┐
│  Flux Controllers       │
│  ├── source-controller  │ ← Pulls from Git/Helm/OCI
│  ├── kustomize-ctrl     │ ← Applies Kustomize overlays
│  ├── helm-ctrl          │ ← Deploys Helm charts
│  └── notification-ctrl  │ ← Alerts on sync failures
└─────────────────────────┘
    │
    │ Applies to cluster
    ▼
Kubernetes Cluster (actual state = desired state)
```

### Flux vs ArgoCD:
| | Flux | ArgoCD |
|---|------|--------|
| UI | Minimal (Weave GitOps) | Rich built-in UI |
| Pull vs Push | Pull-based only | Pull-based + manual sync |
| Multi-tenancy | Native per-namespace | Via Projects |
| Image automation | Built-in | Separate controller |
| CRD-based | Yes (multiple CRDs) | Single Application CRD |

---

## 📋 Labs

| # | Lab | Difficulty | What Breaks |
|---|-----|-----------|-------------|
| 01 | Git Auth Failed | ⭐ Easy | SSH key or token wrong |
| 02 | Kustomization Path Wrong | ⭐⭐ Medium | Path doesn't exist in repo |
| 03 | HelmRelease Values Missing | ⭐⭐ Medium | ConfigMap for values not found |
| 04 | Dependency Not Ready | ⭐⭐⭐ Hard | Source blocks downstream |
| 05 | Image Policy Not Updating | ⭐⭐⭐ Hard | Image automation misconfigured |
| 06 | Health Check Timeout | ⭐⭐ Medium | Custom health check failing |
| 07 | Prune Deleting Resources | ⭐⭐⭐ Hard | Prune removes manual resources |
| 08 | Multi-Tenancy RBAC | ⭐⭐⭐ Hard | SA can't apply to namespace |
| 09 | Webhook Receiver Broken | ⭐⭐ Medium | Webhook not triggering sync |
| 10 | Drift Detection False | ⭐⭐⭐ Hard | Showing changes that don't exist |

---

## 📖 Reference
- Docs: https://fluxcd.io/docs/
- Get Started: https://fluxcd.io/docs/get-started/
