# 🚀 ArgoCD Troubleshooting Labs


## 🚀 How To Use These Labs



### Prerequisites:

- Kubernetes cluster with ArgoCD installed

- `argocd` CLI installed

- `kubectl` configured



### Install ArgoCD (if not installed):

```bash

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

```



### Access ArgoCD Dashboard:

```bash

kubectl port-forward svc/argocd-server -n argocd 8443:443

# Open https://localhost:8443

# Username: admin

# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

```



### Steps:

1. `cd lab-01-sync-failed && ./deploy.sh`

2. Check ArgoCD dashboard - see broken app status

3. Debug: `argocd app get <app-name>`

4. Fix the Application YAML and re-sync

5. Cleanup: `./cleanup.sh`



---


## 10 Real-World Broken ArgoCD Scenarios

Each lab deploys a broken ArgoCD configuration. Your job: diagnose and fix using only `argocd` CLI and `kubectl`.

---

## Labs

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 01 | [Sync Failed](lab-01-sync-failed/) | ⭐ Easy | Application sync fails due to path error |
| 02 | [Health Degraded](lab-02-health-degraded/) | ⭐ Easy | Application health shows Degraded |
| 03 | [Hook Failure](lab-03-hook-failure/) | ⭐⭐ Medium | Pre-sync hook Job fails |
| 04 | [Repo Connection](lab-04-repo-connection/) | ⭐⭐ Medium | Repository connection fails |
| 05 | [App of Apps](lab-05-app-of-apps/) | ⭐⭐ Medium | Child apps fail in app-of-apps pattern |
| 06 | [Resource Exclusion](lab-06-resource-exclusion/) | ⭐⭐⭐ Hard | Resources missing due to exclusion rules |
| 07 | [Sync Waves](lab-07-sync-waves/) | ⭐⭐⭐ Hard | Sync wave ordering causes failures |
| 08 | [Image Updater](lab-08-image-updater/) | ⭐⭐ Medium | ArgoCD Image Updater not updating images |
| 09 | [Multi-Cluster](lab-09-multi-cluster/) | ⭐⭐⭐ Hard | Remote cluster deployment fails |
| 10 | [RBAC Policy](lab-10-rbac-policy/) | ⭐⭐⭐ Hard | RBAC policy blocks application sync |

---

## Prerequisites

- Kubernetes cluster with ArgoCD installed
- `argocd` CLI configured and logged in
- `kubectl` access to the cluster

## Quick Start

```bash
cd lab-01-sync-failed
./deploy.sh
# Observe the error, diagnose, and fix!
./cleanup.sh
```

## Rules

1. Deploy the lab → investigate with `argocd` CLI → identify root cause → fix
2. Don't peek at the README hints until you've tried for 5 minutes
3. Target: solve each lab in under 10 minutes
