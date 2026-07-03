# ☁️ Azure Troubleshooting Labs

## 50 Real-World Broken Azure Scenarios (8+ Year Experience Level)

---

## ⚙️ Prerequisites Setup

### Step 1: Install Azure CLI
```bash
# Linux/WSL:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# macOS:
brew install azure-cli

# Windows (PowerShell):
winget install Microsoft.AzureCLI

# Verify:
az --version
```

### Step 2: Login to Azure
```bash
# Interactive login (opens browser):
az login

# With specific tenant:
az login --tenant YOUR_TENANT_ID

# Service Principal (for automation):
az login --service-principal -u APP_ID -p SECRET --tenant TENANT_ID

# Verify:
az account show
```

### Step 3: Set Subscription
```bash
# List subscriptions:
az account list --output table

# Set active subscription:
az account set --subscription "YOUR_SUBSCRIPTION_NAME_OR_ID"

# Verify:
az account show --query '{Name:name, ID:id, State:state}' --output table
```

### Step 4: Install Azure PowerShell (Optional)
```powershell
# Windows/PowerShell 7+:
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Login:
Connect-AzAccount

# Verify:
Get-AzContext
```

### Step 5: Set Billing Alert (IMPORTANT!)
```bash
# Create a budget with alert at $10:
az consumption budget create \
  --budget-name "LabBudget" \
  --amount 10 \
  --category Cost \
  --time-grain Monthly \
  --start-date $(date +%Y-%m-01) \
  --end-date $(date -d '+1 month' +%Y-%m-01)
```

---

## 🚀 How To Use These Labs

```bash
# Check prerequisites:
./setup-prerequisites.sh

# Run a lab:
cd lab-01-rbac-access-denied
./deploy.sh      # Creates broken Azure resources
# Observe error, diagnose, fix!
./cleanup.sh     # ALWAYS cleanup to avoid charges!
```

---

## 📋 Labs by Category

### 🔐 Identity & RBAC (Labs 01-08)
| # | Lab | Cost | Scenario |
|---|-----|------|----------|
| 01 | rbac-access-denied | FREE | Role assignment missing, can't access resources |
| 02 | service-principal-expired | FREE | SP client secret expired, app can't authenticate |
| 03 | managed-identity-not-working | FREE | System-assigned MI not enabled on VM |
| 04 | conditional-access-blocking | FREE | CA policy blocking legitimate access |
| 05 | pim-activation-failed | FREE | PIM eligible role can't be activated |
| 06 | custom-role-too-restrictive | FREE | Custom role missing required actions |
| 07 | subscription-policy-blocking | FREE | Azure Policy denying resource creation |
| 08 | key-vault-access-denied | $0.03/10k ops | Key Vault access policy vs RBAC conflict |

### 🌐 Networking (Labs 09-18)
| # | Lab | Cost/Hour | Scenario |
|---|-----|-----------|----------|
| 09 | vnet-no-internet | $0.04 | VM can't reach internet: no NAT/public IP |
| 10 | nsg-blocking-traffic | FREE | NSG rules blocking app traffic |
| 11 | vnet-peering-broken | FREE | Peering connected but traffic not flowing |
| 12 | private-endpoint-dns | $0.01 | Private endpoint DNS not resolving |
| 13 | application-gateway-502 | $0.07 | App GW returning 502: backend unhealthy |
| 14 | load-balancer-no-connectivity | $0.03 | LB health probe failing, no backend |
| 15 | vpn-gateway-disconnected | $0.15 | S2S VPN tunnel down |
| 16 | azure-firewall-blocking | $0.13 | Firewall rules too restrictive |
| 17 | dns-zone-not-resolving | FREE | Private DNS zone not linked to VNet |
| 18 | front-door-routing-wrong | $0.04 | Front Door routing to wrong backend |

### ☸️ AKS & Containers (Labs 19-26)
| # | Lab | Cost/Hour | Scenario |
|---|-----|-----------|----------|
| 19 | aks-node-not-ready | $0.10 | AKS nodes NotReady: VM scale set issue |
| 20 | aks-pod-identity-failed | $0.10 | Azure AD Pod Identity not authenticating |
| 21 | aks-ingress-not-working | $0.13 | NGINX Ingress/AGIC not routing traffic |
| 22 | aks-cluster-autoscaler | $0.10 | Autoscaler not scaling: quota, limits |
| 23 | aks-persistent-volume-failed | $0.11 | Azure Disk PVC stuck Pending |
| 24 | acr-pull-denied | $0.02 | AKS can't pull from ACR: auth broken |
| 25 | aks-network-policy-blocking | $0.10 | Azure/Calico policy blocking pod traffic |
| 26 | aks-upgrade-stuck | $0.10 | Cluster upgrade stuck: PDB, node surge |

### ⚡ App Service & Functions (Labs 27-32)
| # | Lab | Cost/Hour | Scenario |
|---|-----|-----------|----------|
| 27 | app-service-502 | $0.02 | App Service 502: app crashing, wrong runtime |
| 28 | function-app-timeout | FREE | Function timeout: binding wrong, cold start |
| 29 | app-service-slot-swap-failed | $0.02 | Deployment slot swap stuck: config mismatch |
| 30 | app-service-vnet-integration | $0.02 | VNet integration not reaching private resources |
| 31 | function-app-scaling-stuck | FREE | Consumption plan not scaling: storage issue |
| 32 | app-service-custom-domain-ssl | $0.02 | Custom domain SSL cert not binding |

### 💾 Storage & Database (Labs 33-40)
| # | Lab | Cost/Hour | Scenario |
|---|-----|-----------|----------|
| 33 | storage-account-access-denied | $0.001 | SAS token expired, firewall blocking, CORS |
| 34 | cosmos-db-request-throttled | $0.05 | Cosmos DB 429 throttling: RU exceeded |
| 35 | sql-database-connection-failed | $0.02 | Azure SQL can't connect: firewall, AAD auth |
| 36 | sql-failover-group-broken | $0.04 | Failover group not syncing, read-only issue |
| 37 | redis-cache-connection-timeout | $0.02 | Redis unreachable: SSL required, firewall |
| 38 | storage-replication-lag | $0.001 | GRS replication lag, data consistency issue |
| 39 | blob-lifecycle-not-working | $0.001 | Lifecycle policy not moving blobs to cool tier |
| 40 | data-factory-pipeline-failed | $0.01 | ADF pipeline: linked service auth, mapping wrong |

### 💰 Cost Management (Labs 41-44)
| # | Lab | Cost | Scenario |
|---|-----|------|----------|
| 41 | cost-unused-resources | FREE | Find unused disks, IPs, NICs, App Service Plans |
| 42 | cost-right-sizing-vms | FREE | VMs over-provisioned: D4s at 3% CPU |
| 43 | cost-reserved-instances | FREE | RI recommendations analysis, wrong family |
| 44 | cost-advisor-recommendations | FREE | Azure Advisor cost suggestions ignored |

### 🏢 Governance & Multi-Subscription (Labs 45-50)
| # | Lab | Cost | Scenario |
|---|-----|------|----------|
| 45 | policy-non-compliant-resources | FREE | Azure Policy: resources not compliant |
| 46 | management-group-inheritance | FREE | Policy/RBAC not inheriting through MG hierarchy |
| 47 | blueprint-assignment-failed | FREE | Blueprint assignment conflicts with existing resources |
| 48 | resource-lock-blocking-delete | FREE | CanNotDelete lock preventing deployments |
| 49 | arm-template-deployment-failed | FREE | ARM/Bicep template errors, what-if analysis |
| 50 | terraform-azurerm-state-issue | FREE | Terraform Azure provider state conflicts |

---

## 🛠️ Essential Azure CLI Commands

```bash
# Identity
az account show                              # Current context
az ad signed-in-user show                    # Current user
az role assignment list --assignee <email>   # My permissions

# Networking
az network vnet list -o table
az network nsg rule list --nsg-name <nsg> -g <rg> -o table
az network nic show-effective-route-table --name <nic> -g <rg>

# AKS
az aks show -n <cluster> -g <rg>
az aks get-credentials -n <cluster> -g <rg>
az aks nodepool list -n <cluster> -g <rg> -o table

# Debugging
az monitor activity-log list --offset 1h -o table
az advisor recommendation list --category Cost -o table
az resource list --tag Lab=azure-lab -o table
```

---

## 💰 Cost Summary

| Category | Labs | Est. Cost (1 hour practice) |
|----------|------|----------------------------|
| 🟢 Identity & RBAC | 01-08 | **FREE** |
| 🟡 Networking | 09-18 | **$0.05-0.15/hour** |
| 🟠 AKS & Containers | 19-26 | **$0.10-0.13/hour** |
| 🟡 App Service | 27-32 | **$0-0.02/hour** |
| 🟡 Database & Storage | 33-40 | **$0.001-0.05/hour** |
| 🟢 Cost Management | 41-44 | **FREE** |
| 🟢 Governance | 45-50 | **FREE** |

**Start with FREE labs (01-08, 41-50) to practice without charges!**

---

## 📖 Reference
- Azure Docs: https://learn.microsoft.com/en-us/azure/
- Azure CLI: https://learn.microsoft.com/en-us/cli/azure/
- Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/
