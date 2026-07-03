# ☸️ Azure Kubernetes Service (AKS) - Complete Portal Step-by-Step Guide

> Every tab, every dropdown, every field — for creating and managing AKS clusters in Azure Portal.

---

## Table of Contents
1. [Create an AKS Cluster (Every Tab Detailed)](#1-create-an-aks-cluster)
2. [Connect to Your Cluster (kubectl)](#2-connect-to-your-cluster)
3. [Add/Modify Node Pools](#3-add-node-pools)
4. [Enable Cluster Autoscaler](#4-enable-cluster-autoscaler)
5. [Configure Networking (CNI vs Kubenet)](#5-configure-networking)
6. [Attach Azure Container Registry (ACR)](#6-attach-acr)
7. [Enable Monitoring & Logging](#7-enable-monitoring)
8. [Upgrade Cluster Version](#8-upgrade-cluster)
9. [Configure RBAC & Azure AD Integration](#9-configure-rbac)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Create an AKS Cluster

### Prerequisites
```
Before creating AKS, ensure you have:
✅ A Resource Group created
✅ Sufficient quota (check: Subscription → Usage + quotas)
✅ Azure CLI installed locally (for kubectl access later)
✅ Contributor role on the subscription/resource group
```

### Step-by-Step

**Step 1: Navigate to AKS**
```
1. Open https://portal.azure.com
2. Search bar → Type "Kubernetes services"
3. Click "Kubernetes services" from results
4. Click "+ Create" → "Create a Kubernetes cluster"
```

---

### BASICS TAB

```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ Select existing or "Create new"      │
│                          │ → Name: "aks-rg" → OK                │
│ Cluster preset           │ "Dev/Test" (cheap) or                │
│ configuration            │ "Standard" (production)              │
│                          │ "Production Standard" / "Production  │
│                          │ Economy" options also available       │
│                          │                                      │
│ Kubernetes cluster name  │ my-aks-cluster                       │
│ Region                   │ East US (or your preferred region)   │
│ Availability zones       │ "Zones 1, 2, 3" for production      │
│                          │ "None" for dev/test (cheaper)        │
│ AKS pricing tier         │ "Free" (no SLA, dev/test)            │
│                          │ "Standard" (99.95% SLA, $0.10/hr)    │
│                          │ "Premium" (99.99% SLA + features)    │
│ Kubernetes version       │ Select latest stable (e.g., 1.28.5)  │
│                          │ Avoid "preview" for production       │
│ Automatic upgrade        │ "Enabled with patch" (recommended)   │
│                          │ Options: None, Patch, Stable, Rapid  │
│ Authentication and       │ "Local accounts with Kubernetes      │
│ Authorization            │ RBAC" (default)                      │
│                          │ OR "Microsoft Entra ID with          │
│                          │ Kubernetes RBAC" (recommended prod)  │
└─────────────────────────────────────────────────────────────────┘

Node pool section (on same Basics tab):
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Node size                │ Click "Choose a size"                │
│                          │ → "Standard_D2s_v3" (2 vCPU, 8 GB)  │
│                          │ Good for dev/test                    │
│                          │ → "Standard_D4s_v3" (4 vCPU, 16 GB) │
│                          │ Good for production                  │
│ Scale method             │ "Autoscale" (recommended)            │
│                          │ OR "Manual"                          │
│ Node count range         │ Min: 1, Max: 5 (if autoscale)       │
│ (if autoscale)           │ Or set fixed count (if manual)       │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Node pools"
```

---

### NODE POOLS TAB

```
You'll see the "agentpool" (system pool) already listed from Basics tab.

To ADD a user node pool:
1. Click "+ Add node pool"
2. Panel opens:
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Node pool name           │ workload (max 12 chars, lowercase)   │
│ Mode                     │ "User" (for workloads)               │
│                          │ "System" mode = runs kube-system pods│
│ OS SKU                   │ "Ubuntu Linux" (default)             │
│                          │ OR "Azure Linux" (lighter)           │
│                          │ OR "Windows Server 2022"             │
│ Availability zones       │ Zones 1, 2, 3 (match cluster)       │
│ Enable Azure Spot        │ ☐ No (or ☑ Yes for cheap batch)     │
│ instances                │ ⚠️ Spot VMs can be evicted!         │
│ Node size                │ Click "Choose a size"                │
│                          │ Standard_D4s_v3 (for workloads)      │
│ Scale method             │ "Autoscale"                          │
│ Minimum node count       │ 2                                    │
│ Maximum node count       │ 10                                   │
│ Max pods per node        │ 30 (default) — range: 10-250        │
│                          │ 110 (kubenet) / 30 (Azure CNI)      │
│ Enable public IP per     │ ☐ No (default)                       │
│ node                     │                                      │
│ Node labels              │ + Add label:                         │
│                          │ Key: workload-type Value: general     │
│ Node taints              │ + Add taint: (optional)              │
│                          │ Key: dedicated Value: gpu            │
│                          │ Effect: NoSchedule                   │
│ OS disk size (GB)        │ 128 (default, range: 30-2048)        │
│ OS disk type             │ "Managed" (default)                  │
│                          │ "Ephemeral" (faster, but data lost)  │
└─────────────────────────────────────────────────────────────────┘

3. Click "Add"

Windows node pool (if needed):
- Same process but select OS SKU: "Windows Server 2022"
- Name: max 6 chars for Windows pools!
- Used for .NET Framework workloads

Click "Next: Networking"
```

---

### NETWORKING TAB

```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Network configuration    │ "Azure CNI" (recommended)            │
│                          │ - Pods get VNet IPs directly         │
│                          │ - Better performance                 │
│                          │ - Required for Windows pools         │
│                          │ OR "kubenet" (basic)                 │
│                          │ - Pods get separate network          │
│                          │ - Uses less IP addresses             │
│                          │ OR "Azure CNI Overlay" (new)         │
│                          │ - Best of both worlds                │
│                          │                                      │
│ Virtual network          │ Select existing VNet or create new   │
│                          │ If existing: choose your VNet        │
│ Cluster subnet           │ Select subnet for nodes              │
│                          │ e.g., "aks-subnet" (needs enough IPs)│
│                          │ ⚠️ /24 = 256 IPs (may not be enough │
│                          │ for Azure CNI with many pods!)       │
│                          │ Recommend /22 or /21 for production  │
│ Kubernetes service       │ 10.0.0.0/16 (default)                │
│ address range            │ CANNOT overlap with VNet!            │
│ Kubernetes DNS service   │ 10.0.0.10 (default, within above)    │
│ IP address               │                                      │
│ DNS name prefix          │ my-aks-cluster-dns                   │
│                          │ (for API server FQDN)                │
│                          │                                      │
│ Network policy           │ "Azure" (Azure-native)               │
│                          │ "Calico" (more features)             │
│                          │ "None" (no network policies)         │
│                          │                                      │
│ Load balancer            │ "Standard" (default, recommended)    │
│                          │ "Basic" (limited, deprecated)        │
└─────────────────────────────────────────────────────────────────┘

Private cluster section:
┌─────────────────────────────────────────────────────────────────┐
│ Enable private cluster   │ ☐ Disabled (API server is public)    │
│                          │ ☑ Enabled (API server private only)  │
│                          │ If enabled:                          │
│ Private DNS zone         │ "System" (Azure manages DNS)         │
│                          │ "None" (you manage DNS)              │
│ Set authorized IP ranges │ ☐ Disabled                           │
│                          │ ☑ Enabled → Enter your office IP:    │
│                          │   203.0.113.0/24                     │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Integrations"
```

---

### INTEGRATIONS TAB

```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Container registry       │ Select existing ACR or "None"        │
│                          │ e.g., "mycompanyacr"                 │
│                          │ This auto-creates AcrPull role       │
│                          │                                      │
│ Azure Policy             │ "Enabled" (recommended for prod)     │
│                          │ Enforces pod security standards      │
│                          │                                      │
│ Azure Key Vault Secrets  │ "Enabled" (recommended)              │
│ Provider                 │ Mount Key Vault secrets as volumes   │
│                          │ If enabled:                          │
│   Secret rotation        │ "Enabled"                            │
│   Rotation interval      │ "2m" (2 minutes, default)            │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Monitoring"
```

---

### MONITORING TAB

```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Azure Monitor            │                                      │
│   Container insights     │ "Enabled" (recommended!)             │
│   Log Analytics          │ Select existing workspace or         │
│   workspace              │ "Create new" → Name: aks-logs        │
│   Managed Prometheus     │ "Enabled" (metrics collection)       │
│   Managed Grafana        │ Select or create Grafana instance    │
│                          │                                      │
│ Alert rules              │                                      │
│   Recommended alert      │ ☑ Enable recommended alerts          │
│   rules                  │ (CPU, memory, OOM alerts)            │
│                          │                                      │
│ Cost analysis            │                                      │
│   Cost analysis          │ "Enabled" (see AKS cost breakdown)  │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Advanced"
```

---

### ADVANCED TAB

```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Infrastructure resource  │ Leave default (auto-named MC_...)     │
│ group                    │ Or specify custom name               │
│                          │                                      │
│ Enable secret store CSI  │ ☑ Enabled (if using Key Vault)       │
│ driver                   │                                      │
│                          │                                      │
│ Enable HTTP application  │ ☑ Enabled (built-in ingress)         │
│ routing                  │ Simpler than deploying NGINX yourself │
│                          │                                      │
│ Enable Open Service Mesh │ ☐ Disabled (unless needed)           │
│                          │                                      │
│ Enable OIDC issuer       │ ☑ Enabled (for workload identity)    │
│                          │                                      │
│ Enable workload identity │ ☑ Enabled (pod → Azure resources)    │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Tags"
```

---

### TAGS TAB

```
Add tags:
- Name: Environment     Value: Production
- Name: Team            Value: Platform
- Name: CostCenter      Value: Engineering
- Name: ManagedBy       Value: DevOps

Click "Next: Review + create"
```

---

### REVIEW + CREATE

```
1. Azure runs validation (30 seconds)
2. Review ALL settings displayed
3. Check the estimated cost shown at top
4. Click "Create"
5. ⏱️ Deployment takes 5-10 minutes
6. ✅ "Deployment complete" → Click "Go to resource"
```

---

## 2. Connect to Your Cluster

### Step-by-Step

**Step 1: Get Credentials (from Portal)**
```
1. Open your AKS cluster in Portal
2. Click "Connect" button at the top
3. You'll see commands to run:

   az account set --subscription YOUR-SUB-ID
   az aks get-credentials --resource-group aks-rg --name my-aks-cluster

4. Open your local terminal and run these commands
```

**Step 2: Verify Connection**
```bash
# Check nodes are ready
kubectl get nodes
# Expected output:
# NAME                          STATUS   ROLES   AGE   VERSION
# aks-agentpool-12345-vmss000  Ready    agent   5m    v1.28.5
# aks-workload-67890-vmss000   Ready    agent   5m    v1.28.5

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info
```

**Step 3: Access from Portal (Cloud Shell)**
```
1. In AKS Overview → Click "Connect" 
2. Click "Open Cloud Shell" button
3. Cloud Shell opens at bottom of Portal
4. Credentials are auto-configured
5. Type: kubectl get nodes
```

---

## 3. Add Node Pools

### Add a Node Pool to Existing Cluster

**Step 1: Navigate**
```
1. Open your AKS cluster
2. Left menu → "Node pools" (under Settings)
3. Click "+ Add node pool"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Node pool name           │ gpu (max 12 chars)                   │
│ Mode                     │ "User"                               │
│ OS type                  │ Linux                                │
│ Availability zones       │ Zones 1, 2, 3                        │
│ Enable Azure Spot        │ ☐ No                                 │
│ Node size                │ Standard_NC6s_v3 (GPU node)          │
│ Scale method             │ Manual (for GPU — expensive!)        │
│ Node count               │ 1                                    │
│ Max pods per node        │ 30                                   │
│ OS disk size             │ 128 GB                               │
│ OS disk type             │ Managed                              │
│                          │                                      │
│ Node labels:             │ hardware: gpu                        │
│ Node taints:             │ nvidia.com/gpu=present:NoSchedule    │
└─────────────────────────────────────────────────────────────────┘

Click "Add"
⏱️ Takes 3-5 minutes to provision nodes
```

### Scale a Node Pool
```
1. Node pools → Click on the pool name
2. Click "Scale node pool" at the top
3. Change "Node count" → e.g., from 2 to 5
4. Click "Apply"
```

### Delete a Node Pool
```
1. Node pools → Click the "..." menu on the pool row
2. Click "Delete"
3. Confirm by typing the pool name
4. Click "Delete"
⚠️ Cannot delete the last system pool!
```

---

## 4. Enable Cluster Autoscaler

### On an Existing Node Pool

**Step 1: Navigate**
```
1. AKS cluster → Node pools
2. Click on the node pool name (e.g., "workload")
3. Click "Scale node pool" at top
```

**Step 2: Configure Autoscaler**
```
1. Scale method: Select "Autoscale" (radio button)
2. Minimum node count: 2
3. Maximum node count: 10
4. Click "Apply"
```

### Configure Autoscaler Profile (Cluster-Level)
```
1. AKS cluster → Left menu → "Node pools"
2. At the top, there's no direct UI for profile...
   Use CLI instead:

az aks update \
  --resource-group aks-rg \
  --name my-aks-cluster \
  --cluster-autoscaler-profile \
    scan-interval=10s \
    scale-down-delay-after-add=10m \
    scale-down-unneeded-time=10m \
    max-graceful-termination-sec=600
```

---

## 5. Configure Networking

### Understanding the Networking Options

```
KUBENET (Basic):
┌──────────────────────────────────────────────────────┐
│ Nodes get VNet IPs (10.0.1.x)                       │
│ Pods get NAT'd IPs (10.244.x.x) — NOT in VNet      │
│ Pods reach VNet via NAT through node                │
│ Pro: Uses fewer VNet IPs                            │
│ Con: Extra hop, can't apply NSG to pods             │
│ Max pods/node: 110                                  │
└──────────────────────────────────────────────────────┘

AZURE CNI:
┌──────────────────────────────────────────────────────┐
│ Nodes AND Pods get VNet IPs (10.0.1.x, 10.0.1.y)   │
│ Pods are first-class VNet citizens                  │
│ Pro: Direct VNet access, NSG works on pods          │
│ Con: Uses LOTS of IPs (node_count × max_pods)       │
│ Max pods/node: 30 (default)                         │
│ IP planning: 3 nodes × 30 pods = 90 IPs needed!    │
└──────────────────────────────────────────────────────┘

AZURE CNI OVERLAY:
┌──────────────────────────────────────────────────────┐
│ Nodes get VNet IPs, Pods get overlay IPs            │
│ Like kubenet but with CNI performance               │
│ Pro: Fewer VNet IPs needed + good performance       │
│ Max pods/node: 250                                  │
│ Best for: Large clusters with IP constraints        │
└──────────────────────────────────────────────────────┘
```

### Change Network Policy (Post-Creation: NOT possible in Portal)
```
⚠️ Network configuration CANNOT be changed after cluster creation!
   You must plan networking BEFORE creating the cluster.

If you need to change:
1. Create a NEW cluster with correct networking
2. Migrate workloads
3. Delete old cluster
```

---

## 6. Attach ACR

### From Portal

**Step 1: Navigate**
```
1. AKS cluster → Left menu → "Integrations" (under Settings)
2. Under "Container registry", click the dropdown
3. Select your ACR (e.g., "mycompanyacr")
4. Click "Save"
```

**What This Does:**
```
- Creates AcrPull role assignment on the ACR
- AKS managed identity can now pull images
- Pods can use: image: mycompanyacr.azurecr.io/myapp:v1
```

### Via CLI (Alternative)
```bash
az aks update \
  --resource-group aks-rg \
  --name my-aks-cluster \
  --attach-acr mycompanyacr
```

### Verify ACR Access
```bash
# Check role assignment exists
az role assignment list --scope /subscriptions/SUB/resourceGroups/RG/providers/Microsoft.ContainerRegistry/registries/mycompanyacr --output table

# Test pulling an image
kubectl run test --image=mycompanyacr.azurecr.io/myapp:v1 --restart=Never
kubectl get pod test  # Should be Running, not ImagePullBackOff
kubectl delete pod test
```

---

## 7. Enable Monitoring

### Enable Container Insights (Post-Creation)

**Step 1: Navigate**
```
1. AKS cluster → Left menu → "Insights" (under Monitoring)
2. If not enabled, you'll see "Enable" button
3. Click "Enable"
4. Select or create Log Analytics workspace
5. Click "Configure"
6. ⏱️ Takes 5-10 minutes to start collecting data
```

**Step 2: View Monitoring Data**
```
1. AKS cluster → "Insights"
2. Tabs available:
   - Cluster: Overall CPU/Memory usage
   - Nodes: Per-node resource usage
   - Controllers: Deployment/ReplicaSet health
   - Containers: Per-container metrics
   - Live Logs: Real-time container output

3. Click on any node/pod for detailed drill-down
```

**Step 3: Set Up Alerts**
```
1. AKS cluster → Left menu → "Alerts"
2. Click "+ Create" → "Alert rule"
3. Condition → Select signal:
   - "CPU Usage Percentage" (node level)
   - "Memory Working Set Percentage"
   - "Pod count by phase" (stuck pods)
   - "Restarting container count"
4. Configure threshold:
   - Operator: Greater than
   - Threshold: 80 (for 80% CPU)
   - Aggregation: Average
   - Period: 5 minutes
5. Actions → Select/create Action Group:
   - Email: admin@company.com
   - SMS: +1-555-0123
6. Click "Create"
```

---

## 8. Upgrade Cluster

### Step-by-Step

**Step 1: Check Available Versions**
```
1. AKS cluster → Left menu → "Cluster configuration"
2. Or: Overview → "Kubernetes version" field
3. Click "Upgrade" button (if available)
```

**Step 2: Perform Upgrade**
```
1. AKS cluster → Left menu → "Cluster configuration"
2. Click "Upgrade version" at the top
3. You'll see available versions:
   - Current: 1.27.7
   - Available: 1.28.3 (recommended), 1.28.5
   ⚠️ Can only upgrade ONE minor version at a time!
   (1.27 → 1.28 ✅, 1.27 → 1.29 ❌)

4. Select target version
5. Choose upgrade scope:
   - "Control plane only" (API server only)
   - "Control plane + all node pools" (recommended)
6. Click "Save"
7. ⏱️ Takes 10-30 minutes depending on cluster size
```

**Step 3: Monitor Upgrade**
```
1. AKS cluster → "Activity log"
2. Look for "Upgrade Managed Cluster" operation
3. Status: InProgress → Succeeded
4. Nodes are upgraded one at a time (rolling update):
   - Cordon node → Drain pods → Upgrade → Uncordon
```

---

## 9. Configure RBAC

### Enable Azure AD Integration (During Creation)
```
On Basics tab:
- Authentication and Authorization:
  "Microsoft Entra ID authentication with Kubernetes RBAC"
```

### Add Cluster Admin (Post-Creation)
```
1. AKS cluster → Left menu → "Access control (IAM)"
2. "+ Add" → "Add role assignment"
3. Role: "Azure Kubernetes Service Cluster Admin Role"
   (or "Azure Kubernetes Service Cluster User Role" for read)
4. Members → Select user/group
5. "Review + assign"
```

### Kubernetes RBAC Roles via Portal
```
1. AKS cluster → Left menu → "Namespaces"
2. This shows Kubernetes namespaces
3. For RBAC, use kubectl:

# Create namespace
kubectl create namespace team-a

# Create role
kubectl create role team-a-dev \
  --verb=get,list,create,update,delete \
  --resource=pods,deployments,services \
  --namespace=team-a

# Bind to Azure AD group
kubectl create rolebinding team-a-binding \
  --role=team-a-dev \
  --group=AZURE-AD-GROUP-OBJECT-ID \
  --namespace=team-a
```

---

## 10. Troubleshooting

### ❌ Mistake 1: Nodes Show "NotReady"
```
Problem: kubectl get nodes shows NotReady

Diagnosis (Portal):
1. AKS cluster → Node pools → Click pool → Click node name
2. Check "Status" and "Conditions"
3. Or: AKS → Diagnose and solve problems → "Node health"

Common causes:
- Node ran out of disk space (OS disk too small)
- Node ran out of memory (too many pods)
- VM was deallocated (Spot instance evicted)
- kubelet crashed (check kubelet logs)

Fix:
1. If Spot eviction: Autoscaler will replace it
2. If disk full: Increase OS disk size (requires new pool)
3. If OOM: Reduce pod count or increase node size
4. Manual fix: AKS → Node pools → Click "..." → "Reconcile"
```

### ❌ Mistake 2: ImagePullBackOff from ACR
```
Problem: Pods stuck in ImagePullBackOff

Diagnosis:
kubectl describe pod POD_NAME | grep -A5 "Events"
# Look for: "unauthorized" or "access denied"

Causes:
1. ACR not attached to AKS
2. Image name/tag is wrong
3. ACR is in different subscription
4. AKS managed identity doesn't have AcrPull role

Fix:
1. Portal: AKS → Integrations → Attach ACR
2. Or CLI: az aks update --attach-acr YOUR_ACR
3. Verify image exists: ACR → Repositories → Check tag
4. Check identity: ACR → IAM → Role assignments → Look for AKS
```

### ❌ Mistake 3: Cluster Autoscaler Not Scaling
```
Problem: Pods stuck in Pending but no new nodes

Diagnosis:
kubectl describe pod PENDING_POD | grep -A10 "Events"
# Look for: "FailedScheduling" with reason

Causes:
1. Already at max nodes (check node pool max count)
2. No node size fits pod requirements (CPU/memory request too high)
3. Node taints prevent scheduling
4. Pod has nodeSelector that doesn't match

Fix:
1. Increase max node count: Node pools → Scale → Increase max
2. Reduce pod resource requests
3. Add tolerations to pod spec
4. Fix nodeSelector labels
```

### ❌ Mistake 4: Cannot Connect to API Server
```
Problem: kubectl commands timeout

Diagnosis:
1. Is cluster private? Check: AKS → Networking → Private cluster
2. Are authorized IP ranges set? Check: Networking → API server

Fix:
1. Private cluster: Must connect from within VNet (or use VPN/Bastion)
2. IP ranges: Add your current IP:
   AKS → Networking → Authorized IP ranges → Add your IP
3. Check cluster is running:
   AKS → Overview → Status should be "Succeeded"
4. Check cluster isn't being upgraded (temporarily unavailable)
```

### ❌ Mistake 5: Ingress Not Working (502/404)
```
Problem: External traffic can't reach services

Diagnosis:
1. kubectl get ingress -A (check ADDRESS column has IP)
2. kubectl get svc -n NAMESPACE (check LoadBalancer has EXTERNAL-IP)
3. kubectl describe ingress INGRESS_NAME (check events)

Causes:
1. Ingress controller not installed
2. Service selector doesn't match pod labels
3. Backend pod is crashing (check pod logs)
4. NSG blocking port 80/443 on node subnet

Fix:
1. Install ingress: AKS → Networking → Enable HTTP app routing
   Or: helm install ingress-nginx ingress-nginx/ingress-nginx
2. Check: kubectl get pods -n app-routing-system (or ingress-nginx)
3. Verify: Service → Endpoints (should list pod IPs)
4. Check NSG: VNet → Subnet NSG → Allow 80, 443 inbound
```

### ❌ Mistake 6: Persistent Volume Claim Stuck in Pending
```
Problem: PVC shows Pending, pod can't start

Diagnosis:
kubectl describe pvc PVC_NAME
# Look for events: "waiting for first consumer"

Causes:
1. Storage class doesn't exist
2. Disk and node in different zones
3. Too many disks attached to node (limit varies by VM size)

Fix:
1. Check storage classes: kubectl get sc
   Default classes: managed-csi, managed-csi-premium
2. Use WaitForFirstConsumer binding mode (default)
3. Scale up node pool to spread disk attachments
4. Check VM disk limits: Standard_D4s_v3 = max 8 data disks
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create cluster | Kubernetes services → + Create |
| Connect kubectl | AKS → Connect → Copy commands |
| Add node pool | AKS → Node pools → + Add |
| Scale pool | AKS → Node pools → Scale node pool |
| Attach ACR | AKS → Integrations → Container registry |
| View monitoring | AKS → Insights |
| Upgrade | AKS → Cluster configuration → Upgrade |
| RBAC | AKS → Access control (IAM) |
| Networking | AKS → Networking |
| Diagnose | AKS → Diagnose and solve problems |
| Workloads | AKS → Workloads (see deployments) |
| Services | AKS → Services and ingresses |

---

## 📊 Cost Awareness

```
AKS control plane: FREE (or $0.10/hr for Standard tier SLA)
You pay for: Node VMs + Disks + Networking

Example costs (East US, pay-as-you-go):
- 3x Standard_D2s_v3 (2 vCPU, 8GB): ~$220/month
- 3x Standard_D4s_v3 (4 vCPU, 16GB): ~$440/month
- Load Balancer (Standard): ~$18/month + data
- Managed Disks: ~$8/month per 128GB Premium SSD

Cost saving tips:
- Use Spot instances for non-critical workloads (60-90% discount!)
- Enable autoscaler to scale down at night
- Use Azure Reserved Instances for base capacity
- Choose the right VM size (don't over-provision)
- Delete dev/test clusters when not in use
```

---

## 🔗 Related Labs
- [Lab 19: AKS Node Not Ready](../lab-19-aks-node-not-ready/)
- [Lab 20: AKS Pod Identity Failed](../lab-20-aks-pod-identity-failed/)
- [Lab 21: AKS Ingress Not Working](../lab-21-aks-ingress-not-working/)
- [Lab 22: AKS Cluster Autoscaler](../lab-22-aks-cluster-autoscaler/)
- [Lab 23: AKS Persistent Volume Failed](../lab-23-aks-persistent-volume-failed/)
- [Lab 24: ACR Pull Denied](../lab-24-acr-pull-denied/)
- [Lab 25: AKS Network Policy Blocking](../lab-25-aks-network-policy-blocking/)
- [Lab 26: AKS Upgrade Stuck](../lab-26-aks-upgrade-stuck/)
