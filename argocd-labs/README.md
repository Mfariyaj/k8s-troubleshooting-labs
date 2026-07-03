# 🚀 ArgoCD Troubleshooting Labs

## 15 Real-World Broken ArgoCD Scenarios

Each lab deploys a broken ArgoCD Application. Your job: diagnose and fix using `argocd` CLI, `kubectl`, and the ArgoCD dashboard.

---

## ⚙️ One-Time Setup (Do This Before Any Lab)

### Step 1: Install ArgoCD in Your Cluster
```bash
# Automatic (recommended):
./install-argocd.sh

# OR manual:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

### Step 2: Install ArgoCD CLI
```bash
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
argocd version --client    # Verify: should show version
```

### Step 3: Start Port-Forward (Run in Separate Terminal — Keep Open!)
```bash
kubectl port-forward svc/argocd-server -n argocd 8443:443
```
⚠️ This terminal must stay open while you work on labs!

### Step 4: Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo ""
```

### Step 5: Login to ArgoCD CLI
```bash
argocd login localhost:8443 --username admin --password <password-from-step-4> --insecure
```
✅ You should see: `'admin:login' logged in successfully`

### Step 6: Open ArgoCD Dashboard (Browser)
- **URL:** https://localhost:8443
- **Username:** admin
- **Password:** (from Step 4)
- Accept the self-signed certificate warning in browser

---

## 🎯 How to Run a Lab

```bash
# Deploy the broken app:
cd lab-01-sync-failed
./deploy.sh

# Check the error (CLI):
argocd app get sync-failed-app

# Or check on dashboard: https://localhost:8443

# Fix the YAML, re-apply:
kubectl apply -f application.yaml

# Verify fix:
argocd app get sync-failed-app    # Should show: Synced + Healthy

# Cleanup when done:
./cleanup.sh

# Move to next lab:
cd ../lab-02-health-degraded
./deploy.sh
```

---

## ⚠️ Common Issues & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `argocd: command not found` | CLI not installed | Run Step 2 above |
| `Failed to establish connection to localhost:8082` | Not logged in | Run: `argocd login localhost:8443 --username admin --password <pass> --insecure` |
| `connection refused` on port 8443 | Port-forward not running | Open new terminal: `kubectl port-forward svc/argocd-server -n argocd 8443:443` |
| `ComparisonError: app path is absolute` | **This is the bug!** Lab working as expected | Fix the `path:` field in application.yaml |
| Port-forward keeps dying | Normal after idle timeout | Just restart the port-forward command |

---

## 📋 Labs

| # | Lab | Difficulty | What's Broken | Expected Error |
|---|-----|-----------|---------------|----------------|
| 01 | [Sync Failed](lab-01-sync-failed/) | ⭐ Easy | Wrong repo path | `ComparisonError: app path is absolute` |
| 02 | [Health Degraded](lab-02-health-degraded/) | ⭐ Easy | Bad image tag | Health: `Degraded`, pods `ImagePullBackOff` |
| 03 | [Hook Failure](lab-03-hook-failure/) | ⭐⭐ Medium | PreSync job wrong image | `SyncFailed: hook failed` |
| 04 | [Repo Connection](lab-04-repo-connection/) | ⭐⭐ Medium | Bad credentials/URL | `repository not accessible` |
| 05 | [App of Apps](lab-05-app-of-apps/) | ⭐⭐ Medium | Wrong project reference | `not permitted in project` |
| 06 | [Resource Exclusion](lab-06-resource-exclusion/) | ⭐⭐⭐ Hard | Overly broad exclusion regex | Resources missing silently |
| 07 | [Sync Waves](lab-07-sync-waves/) | ⭐⭐⭐ Hard | DB in wave 3, app in wave 1 | App crashes (DB not ready) |
| 08 | [Image Updater](lab-08-image-updater/) | ⭐⭐ Medium | Wrong annotation key | Image stays at old version |
| 09 | [Multi-Cluster](lab-09-multi-cluster/) | ⭐⭐⭐ Hard | Expired cluster token | `cluster not accessible` |
| 10 | [RBAC Policy](lab-10-rbac-policy/) | ⭐⭐⭐ Hard | Policy syntax error | `permission denied` on sync |
| 11 | [Custom Health Check](lab-11-custom-health-check/) | ⭐⭐⭐⭐ Expert | Lua script errors | Always shows `Progressing` |
| 12 | [ApplicationSet Generator](lab-12-applicationset-generator/) | ⭐⭐⭐⭐ Expert | Wrong generator config | Duplicate/missing apps |
| 13 | [Notification Controller](lab-13-notification-controller/) | ⭐⭐⭐⭐ Expert | Template errors | Notifications never sent |
| 14 | [Server-Side Apply](lab-14-server-side-apply-conflicts/) | ⭐⭐⭐⭐ Expert | Field conflicts with HPA | Constant OutOfSync |
| 15 | [Multi-Source Application](lab-15-multi-source-application/) | ⭐⭐⭐⭐ Expert | Ref mismatch between sources | Values not applied |

---

## 🛠️ Useful Debugging Commands

```bash
# App overview
argocd app get <app-name>
argocd app list

# Sync manually
argocd app sync <app-name>

# See diff (what would change)
argocd app diff <app-name>

# View app events/history
argocd app history <app-name>

# Check app resources
argocd app resources <app-name>

# Force refresh from git
argocd app get <app-name> --refresh

# Delete an app
argocd app delete <app-name>

# kubectl alternatives (no argocd CLI needed):
kubectl get applications -n argocd
kubectl get application <app-name> -n argocd -o yaml
kubectl describe application <app-name> -n argocd
```

---

## 📁 File Structure (each lab)

```
lab-XX-name/
├── application.yaml    # The BROKEN ArgoCD Application manifest
├── README.md           # Scenario, expected error, hints
├── solution.md         # Full fix with explanation
├── deploy.sh           # Deploys the broken app: kubectl apply -f application.yaml
└── cleanup.sh          # Removes everything: kubectl delete -f application.yaml
```

---

## Prerequisites

- Kubernetes cluster (minikube, kind, k3s, Docker Desktop, EKS)
- `kubectl` configured and connected
- ArgoCD installed (use `./install-argocd.sh`)
- `argocd` CLI installed
- Port 8443 available for port-forward
