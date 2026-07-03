# 📚 Azure Complete Learning Guide

## Learn Every Azure Service Covered in These Labs (From Scratch)

---

# 🔐 1. Identity & Access Management (Azure AD / Entra ID)

## What is it?
Azure AD (now called Microsoft Entra ID) is the **identity and access management** service. It's like a bouncer at a club — it checks WHO you are and WHAT you're allowed to do.

## Key Concepts:

### Users & Groups
```
User = A person (email: john@company.com)
Group = Collection of users (e.g., "DevOps Team")
Guest = External user invited to your directory
```

### Service Principals & Managed Identities
```
Service Principal (SP) = An "app identity" (like a robot user)
  - Used by: CI/CD pipelines, Terraform, applications
  - Has: Client ID + Client Secret (or certificate)
  - Secret EXPIRES! (common issue in Lab 02)

Managed Identity = Azure-managed SP (no secrets to manage!)
  - System-assigned: tied to one resource (VM, App Service)
  - User-assigned: reusable across multiple resources
  - Azure handles rotation automatically ✅
```

### RBAC (Role-Based Access Control)
```
WHO (Principal) + WHAT (Role) + WHERE (Scope) = Access

Example:
  WHO:   john@company.com
  WHAT:  Contributor (can create/modify/delete)
  WHERE: /subscriptions/xxx/resourceGroups/my-rg

Built-in Roles:
  Owner         = Full access + can assign roles
  Contributor   = Full access but can't assign roles
  Reader        = Read-only
  User Access Admin = Only manages role assignments
```

### Portal: How to Assign a Role
```
1. Go to Resource/Resource Group/Subscription
2. Click "Access control (IAM)" in left menu
3. Click "+ Add" → "Add role assignment"
4. Select Role → Select User/SP → Save
```

### CLI:
```bash
# List my roles
az role assignment list --assignee "john@company.com" --output table

# Assign a role
az role assignment create \
  --assignee "john@company.com" \
  --role "Contributor" \
  --scope "/subscriptions/xxx/resourceGroups/my-rg"

# List available roles
az role definition list --query "[].{Name:roleName, Description:description}" --output table
```

---

# 🌐 2. Networking (VNet, NSG, Load Balancer, etc.)

## Architecture Overview:
```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Azure Region (e.g., East US)                         │
│                                                      │
│  ┌─────────────────────────────────────────────┐    │
│  │ Virtual Network (VNet) - 10.0.0.0/16        │    │
│  │                                              │    │
│  │  ┌──────────────────────┐                   │    │
│  │  │ Subnet 1 (Public)    │  NSG ← rules     │    │
│  │  │ 10.0.1.0/24          │                   │    │
│  │  │ [Load Balancer]      │                   │    │
│  │  │ [App Gateway]        │                   │    │
│  │  └──────────────────────┘                   │    │
│  │                                              │    │
│  │  ┌──────────────────────┐                   │    │
│  │  │ Subnet 2 (Private)   │  NSG ← rules     │    │
│  │  │ 10.0.2.0/24          │                   │    │
│  │  │ [VMs / AKS nodes]    │  NAT Gateway      │    │
│  │  └──────────────────────┘  (for outbound)   │    │
│  │                                              │    │
│  │  ┌──────────────────────┐                   │    │
│  │  │ Subnet 3 (Database)  │  NSG ← rules     │    │
│  │  │ 10.0.3.0/24          │                   │    │
│  │  │ [SQL / Redis]        │  Private Endpoint  │    │
│  │  └──────────────────────┘                   │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

## Key Services:

### VNet (Virtual Network)
- **What:** Your private network in Azure (like your office LAN in the cloud)
- **Why:** Isolate resources, control traffic flow
- **Address space:** e.g., 10.0.0.0/16 (65,536 IPs)
- **Subnets:** Divide VNet into segments (public, private, database)

### NSG (Network Security Group)
- **What:** Firewall rules for subnets or individual NICs
- **Rules:** Priority-based (100-4096), Allow or Deny, Inbound or Outbound
- **Default:** Allows VNet-to-VNet, denies internet inbound
```bash
# List NSG rules
az network nsg rule list --nsg-name my-nsg -g my-rg --output table

# Add rule to allow port 443
az network nsg rule create \
  --nsg-name my-nsg -g my-rg \
  --name AllowHTTPS \
  --priority 100 \
  --access Allow \
  --direction Inbound \
  --protocol Tcp \
  --destination-port-ranges 443
```

### NAT Gateway
- **What:** Gives private subnet VMs internet access (outbound only)
- **Like AWS:** Same as AWS NAT Gateway
- **Cost:** ~$0.045/hour + data processing

### Private Endpoint
- **What:** Puts an Azure service (SQL, Storage) INSIDE your VNet
- **Why:** No public internet exposure for databases
- **How:** Creates a private IP (10.0.x.x) for the service + DNS record

### VNet Peering
- **What:** Connects two VNets together (like a bridge)
- **Traffic:** Stays on Azure backbone (fast, cheap)
- **Rules:** Must be created in BOTH VNets (bidirectional)

### Azure Load Balancer vs Application Gateway
| | Load Balancer | Application Gateway |
|---|---|---|
| Layer | L4 (TCP/UDP) | L7 (HTTP/HTTPS) |
| Features | Port forwarding, health probes | URL routing, SSL termination, WAF |
| Use case | Non-HTTP traffic, internal LB | Web apps, API routing |
| Cost | ~$0.03/hour | ~$0.07/hour |

---

# ☸️ 3. AKS (Azure Kubernetes Service)

## What is it?
AKS is **managed Kubernetes** on Azure. Azure manages the control plane (API server, etcd, scheduler), you manage the worker nodes.

## Architecture:
```
┌──────────────────────────────────────────────────┐
│ AKS Cluster                                       │
│                                                   │
│  ┌─────────────────────┐  ← Azure manages this   │
│  │ Control Plane (FREE)│                          │
│  │ - API Server        │                          │
│  │ - etcd              │                          │
│  │ - Scheduler         │                          │
│  └─────────────────────┘                          │
│           │                                       │
│           ▼                                       │
│  ┌─────────────────────┐  ← You pay for these    │
│  │ Node Pool (VMSS)    │                          │
│  │ - Node 1 (VM)       │                          │
│  │ - Node 2 (VM)       │                          │
│  │ - Node 3 (VM)       │                          │
│  └─────────────────────┘                          │
│                                                   │
│  Addons:                                          │
│  - Azure CNI (networking)                         │
│  - Azure Disk CSI (storage)                       │
│  - NGINX Ingress / AGIC (routing)                 │
│  - Workload Identity (auth)                       │
└──────────────────────────────────────────────────┘
```

## Key Concepts:
| Concept | What | CLI |
|---------|------|-----|
| Cluster | The K8s environment | `az aks create` |
| Node Pool | Group of VMs (workers) | `az aks nodepool add` |
| Workload Identity | Pod → Azure auth (replaces Pod Identity) | Annotations on SA |
| AGIC | App GW Ingress Controller (L7 load balancer) | Addon |
| ACR | Container registry (store images) | `az acr create` |

## Common Commands:
```bash
# Create cluster
az aks create -n myaks -g myrg --node-count 3 --generate-ssh-keys

# Get credentials (configures kubectl)
az aks get-credentials -n myaks -g myrg

# Scale nodes
az aks scale -n myaks -g myrg --node-count 5

# Attach ACR (so AKS can pull images)
az aks update -n myaks -g myrg --attach-acr myacr

# Check cluster health
az aks show -n myaks -g myrg --query powerState
kubectl get nodes
```

---

# ⚡ 4. App Service & Azure Functions

## App Service (Web Apps)
- **What:** Fully managed platform to host web apps (like Heroku but enterprise)
- **Supports:** .NET, Java, Node.js, Python, PHP, Ruby, containers
- **No infra management:** Azure handles OS, patching, scaling

```bash
# Create web app
az webapp create -n myapp -g myrg --plan myplan --runtime "NODE:18-lts"

# Deploy code
az webapp deployment source config-zip -n myapp -g myrg --src app.zip

# View logs
az webapp log tail -n myapp -g myrg

# Scale out (more instances)
az appservice plan update -n myplan -g myrg --sku P1V2 --number-of-workers 3
```

## Azure Functions (Serverless)
- **What:** Run code without managing servers (pay per execution)
- **Triggers:** HTTP, Timer, Queue, Blob, Event Grid, Cosmos DB
- **Plans:** Consumption ($0 when idle), Premium (always warm), Dedicated

```bash
# Create function app
az functionapp create -n myfunc -g myrg --consumption-plan-location eastus \
  --runtime python --functions-version 4 --storage-account mystorage

# Deploy
func azure functionapp publish myfunc
```

---

# 💾 5. Storage & Database

## Storage Account
- **What:** Stores blobs (files), tables, queues, file shares
- **Tiers:** Hot (frequent access), Cool (30 days), Archive (180 days)
- **Redundancy:** LRS, ZRS, GRS, GZRS

```bash
# Create storage account
az storage account create -n mystorage -g myrg --sku Standard_LRS

# Upload blob
az storage blob upload --account-name mystorage -c mycontainer -f file.txt -n file.txt

# Generate SAS token (temporary access)
az storage account generate-sas --account-name mystorage --permissions rw --expiry 2024-12-31
```

## Azure SQL Database
- **What:** Managed SQL Server in the cloud
- **Serverless:** Auto-pause when idle (saves money!)
- **Tiers:** Basic ($5/month), Standard, Premium, Hyperscale

```bash
# Create SQL server + database
az sql server create -n myserver -g myrg -u admin -p 'P@ssw0rd!' -l eastus
az sql db create -n mydb -g myrg -s myserver --service-objective S0

# Allow Azure services
az sql server firewall-rule create -g myrg -s myserver -n AllowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
```

## Cosmos DB
- **What:** Globally distributed NoSQL database
- **APIs:** SQL (document), MongoDB, Cassandra, Gremlin, Table
- **Pricing:** Request Units (RU/s) — pay for throughput

## Redis Cache
- **What:** In-memory cache for fast data access
- **Use:** Session state, caching, message broker
- **⚠️:** SSL required by default (port 6380, not 6379!)

---

# 💰 6. Cost Management

## Key Tools:
| Tool | What It Does | Where |
|------|-------------|-------|
| **Cost Analysis** | See spending breakdown | Portal → Cost Management |
| **Budgets** | Set spending alerts | Portal → Budgets |
| **Advisor** | Recommendations to save money | Portal → Advisor |
| **Reservations** | 1-3 year commitments (save 40-72%) | Portal → Reservations |

## Common Cost Savings:
```bash
# Find unused resources
az disk list --query "[?managedBy==null].{Name:name, Size:diskSizeGb, RG:resourceGroup}" -o table
az network public-ip list --query "[?ipConfiguration==null].{Name:name, RG:resourceGroup}" -o table
az network nic list --query "[?virtualMachine==null].{Name:name, RG:resourceGroup}" -o table

# Azure Advisor cost recommendations
az advisor recommendation list --category Cost -o table

# Auto-shutdown VMs (dev/test)
az vm auto-shutdown -n myvm -g myrg --time 1900 --timezone "India Standard Time"
```

---

# 🏢 7. Governance (Policy, Management Groups, Blueprints)

## Azure Policy
- **What:** Enforce rules across all resources (e.g., "all VMs must have tags")
- **Effect:** Deny (block), Audit (log), Append (add field), DeployIfNotExists

```bash
# List non-compliant resources
az policy state list --filter "complianceState eq 'NonCompliant'" -o table

# Assign a built-in policy (require tags)
az policy assignment create \
  --name "require-env-tag" \
  --policy "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-..." \
  --scope "/subscriptions/xxx" \
  --params '{"tagName": {"value": "Environment"}}'
```

## Management Groups
```
Root Management Group
├── Production MG
│   ├── Prod Subscription 1
│   └── Prod Subscription 2
├── Development MG
│   ├── Dev Subscription
│   └── Test Subscription
└── Sandbox MG
    └── Sandbox Subscription
```
- Policies applied at MG level inherit DOWN to all subscriptions

## Resource Locks
- **CanNotDelete:** Prevents deletion (but allows modification)
- **ReadOnly:** Prevents any changes (including delete)
```bash
az lock create -n no-delete -g myrg --lock-type CanNotDelete
```

---

# 📖 Quick Reference: Azure vs AWS Mapping

| AWS Service | Azure Equivalent | Purpose |
|------------|-----------------|---------|
| IAM | Azure AD / RBAC | Identity & access |
| VPC | VNet | Private networking |
| EC2 | Virtual Machines | Compute |
| EKS | AKS | Managed Kubernetes |
| S3 | Blob Storage | Object storage |
| RDS | Azure SQL / Cosmos DB | Databases |
| Lambda | Azure Functions | Serverless |
| ELB/ALB | Load Balancer / App Gateway | Load balancing |
| Route53 | Azure DNS | DNS |
| CloudFormation | ARM Templates / Bicep | IaC |
| CloudWatch | Azure Monitor | Monitoring |
| Organizations | Management Groups | Multi-account |
| Config | Azure Policy | Compliance |

---

# 🎯 Learning Path (Recommended Order)

1. **Start here:** Labs 01-08 (Identity) — FREE, fundamental
2. **Then:** Labs 10-17 (Networking) — understand VNets, NSGs
3. **Then:** Labs 19-26 (AKS) — if you work with Kubernetes
4. **Then:** Labs 27-32 (App Service) — if you deploy web apps
5. **Then:** Labs 33-40 (Databases) — storage and data layer
6. **Finally:** Labs 41-50 (Cost + Governance) — senior engineer topics

---

## 📖 Official Learning Resources
- Microsoft Learn (FREE!): https://learn.microsoft.com/en-us/training/azure/
- AZ-104 Study Guide: https://learn.microsoft.com/en-us/certifications/azure-administrator/
- AZ-400 (DevOps): https://learn.microsoft.com/en-us/certifications/devops-engineer/
- Pricing Calculator: https://azure.microsoft.com/en-us/pricing/calculator/

---

# 🌐 Azure Networking - Complete Deep Dive

## All Connectivity Options:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CONNECTIVITY OPTIONS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐    │
│  │ Site-to-Site │   │Point-to-Site │   │    ExpressRoute       │    │
│  │    (S2S)     │   │   (P2S)      │   │  (Private fiber)     │    │
│  │              │   │              │   │                       │    │
│  │ Office ↔ Az │   │ Laptop ↔ Az │   │ Datacenter ↔ Azure   │    │
│  │ VPN Device   │   │ VPN Client   │   │ Dedicated line       │    │
│  │ IPSec tunnel │   │ SSL/IKEv2    │   │ 50Mbps - 10Gbps     │    │
│  │ ~$0.04/hour  │   │ ~$0.04/hour  │   │ ~$200-5000/month    │    │
│  └──────────────┘   └──────────────┘   └──────────────────────┘    │
│                                                                      │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────────┐    │
│  │ VNet Peering │   │ VNet-to-VNet │   │   Virtual WAN        │    │
│  │              │   │    VPN       │   │                       │    │
│  │ VNet ↔ VNet │   │ VNet ↔ VNet │   │  Hub-Spoke at scale  │    │
│  │ Same/cross   │   │ Cross-region │   │  Branch + VNet +     │    │
│  │ region       │   │ encrypted    │   │  P2S + S2S + ER     │    │
│  │ ~$0.01/GB    │   │ ~$0.04/hour  │   │  ~$0.05/hour        │    │
│  └──────────────┘   └──────────────┘   └──────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🏢 Site-to-Site VPN (S2S) — Connect Your Office to Azure

### What is it?
Connects your **on-premises network** (office/data center) to Azure VNet over an encrypted IPSec tunnel through the public internet.

### Architecture:
```
┌─────────────────────┐         Internet          ┌─────────────────────┐
│  On-Premises Office │◄═══════IPSec═══════════►│  Azure VNet          │
│                     │         Tunnel            │                     │
│  Network: 192.168.0.0/16                       │  Network: 10.0.0.0/16│
│                     │                          │                     │
│  ┌───────────────┐  │                          │  ┌───────────────┐  │
│  │ VPN Device    │  │   Shared Key / Cert      │  │ VPN Gateway   │  │
│  │ (Router/FW)   │──┼──────────────────────────┼──│ (GatewaySubnet)│ │
│  │ Public IP:    │  │                          │  │ Public IP:    │  │
│  │ 203.0.113.10  │  │                          │  │ 40.85.xxx.xxx │  │
│  └───────────────┘  │                          │  └───────────────┘  │
│                     │                          │                     │
│  [Servers]          │                          │  [VMs / AKS]       │
│  [Workstations]     │                          │  [Databases]       │
└─────────────────────┘                          └─────────────────────┘
```

### When to Use:
- Connect office servers to Azure VMs
- Hybrid cloud (some workloads on-prem, some in Azure)
- Disaster recovery (replicate to Azure)

### Portal Setup:
1. **Create Virtual Network Gateway:**
   - Portal → Create Resource → "Virtual Network Gateway"
   - Gateway type: VPN
   - VPN type: Route-based
   - SKU: VpnGw1 (~$0.19/hour)
   - VNet: Select your VNet
   - Subnet: GatewaySubnet (auto-created, needs /27 minimum)
   - Public IP: Create new
   - ⏱️ Takes 30-45 minutes to deploy!

2. **Create Local Network Gateway (your on-prem):**
   - Portal → Create Resource → "Local Network Gateway"
   - IP address: Your office VPN device's public IP
   - Address space: Your on-prem network (e.g., 192.168.0.0/16)

3. **Create Connection:**
   - VPN Gateway → Connections → Add
   - Connection type: Site-to-site (IPSec)
   - Local network gateway: (from step 2)
   - Shared key: Same key configured on your VPN device!

4. **Configure On-Prem VPN Device:**
   - Download config from Azure Portal (supports Cisco, Juniper, etc.)
   - Set shared key
   - Configure IKE/IPSec parameters

### CLI:
```bash
# Create VPN Gateway (takes 30-45 min!)
az network vnet-gateway create \
  -n MyVpnGateway -g MyRG \
  --vnet MyVNet \
  --public-ip-addresses MyGatewayIP \
  --gateway-type Vpn \
  --vpn-type RouteBased \
  --sku VpnGw1

# Create Local Network Gateway (your office)
az network local-gateway create \
  -n MyOffice -g MyRG \
  --gateway-ip-address 203.0.113.10 \
  --local-address-prefixes 192.168.0.0/16

# Create the S2S Connection
az network vpn-connection create \
  -n Office-to-Azure -g MyRG \
  --vnet-gateway1 MyVpnGateway \
  --local-gateway2 MyOffice \
  --shared-key "MySecretKey123!"

# Check connection status
az network vpn-connection show -n Office-to-Azure -g MyRG --query connectionStatus
# Should show: "Connected"
```

### Common Issues (Lab 15):
| Issue | Cause | Fix |
|-------|-------|-----|
| Status: NotConnected | Shared key mismatch | Same key on both sides |
| Status: Connecting (stuck) | On-prem device firewall | Open UDP 500, 4500 |
| Slow throughput | Wrong SKU | Upgrade VpnGw1→VpnGw2 |
| Intermittent drops | IKE lifetime mismatch | Match SA lifetime on both |

---

## 💻 Point-to-Site VPN (P2S) — Connect Your Laptop to Azure

### What is it?
Connects **individual devices** (laptops, developer workstations) to Azure VNet. Like a corporate VPN but to Azure.

### Architecture:
```
┌──────────────┐
│ Developer    │         ┌─────────────────────┐
│ Laptop       │────────►│ Azure VPN Gateway   │
│ (VPN Client) │  SSL/   │ (Point-to-Site)     │
└──────────────┘  IKEv2  │                     │
                         │ Assigns IP from:    │
┌──────────────┐         │ 172.16.0.0/24       │
│ Admin        │────────►│                     │
│ Laptop       │         │ Routes to VNet:     │
└──────────────┘         │ 10.0.0.0/16         │
                         └─────────────────────┘
                                  │
                                  ▼
                         ┌─────────────────────┐
                         │ Azure VNet           │
                         │ 10.0.0.0/16         │
                         │ [VMs] [AKS] [SQL]   │
                         └─────────────────────┘
```

### When to Use:
- Developers need to access private Azure resources from home
- Remote workers connecting to internal apps
- Smaller teams (up to ~100 connections per gateway)

### Auth Methods:
| Method | Best For | Setup |
|--------|----------|-------|
| Azure Certificate | Small teams | Generate cert, install on client |
| Azure AD | Enterprise | SSO with corporate credentials |
| RADIUS | Existing RADIUS server | Integrate with NPS |

### Portal Setup:
1. **VPN Gateway** → Point-to-site configuration
2. Address pool: `172.16.0.0/24` (IPs assigned to clients)
3. Tunnel type: OpenVPN (recommended) or IKEv2
4. Authentication: Azure AD or Certificate
5. **Download VPN client** → Install on your laptop
6. Connect!

### CLI:
```bash
# Configure P2S on existing gateway
az network vnet-gateway update \
  -n MyVpnGateway -g MyRG \
  --address-prefixes 172.16.0.0/24 \
  --client-protocol OpenVPN

# Generate VPN client config
az network vnet-gateway vpn-client generate \
  -n MyVpnGateway -g MyRG

# Download and install the client package on your laptop
```

---

## 🔌 ExpressRoute — Private Dedicated Connection

### What is it?
A **private fiber connection** from your data center to Azure. Does NOT go over the public internet — dedicated, fast, reliable.

### Architecture:
```
┌──────────────────┐                              ┌─────────────────┐
│ Your Data Center │                              │ Azure Region    │
│                  │                              │                 │
│  [Servers]       │     ┌──────────────────┐    │  [VNets]        │
│  [Storage]       │─────│ ExpressRoute     │────│  [Services]     │
│  [Network]       │     │ Circuit          │    │  [Microsoft 365]│
│                  │     │ (50M-10Gbps)     │    │                 │
│  Connect via:    │     │                  │    │                 │
│  - ISP/Carrier   │     │ Peering:         │    │                 │
│  - Colocation    │     │  - Private (VNet)│    │                 │
│  - Exchange      │     │  - Microsoft(M365)    │                 │
└──────────────────┘     └──────────────────┘    └─────────────────┘
```

### When to Use:
- Large data transfers (TB/daily)
- Low latency requirement (<10ms)
- Regulatory compliance (data can't traverse public internet)
- Bandwidth: 50Mbps to 10Gbps

### Cost:
| Bandwidth | Metered (per GB) | Unlimited |
|-----------|-----------------|-----------|
| 50 Mbps | $55/month + $0.025/GB | $100/month |
| 1 Gbps | $270/month + $0.025/GB | $600/month |
| 10 Gbps | $1,800/month + $0.025/GB | $5,000/month |

---

## 🔒 Azure Firewall vs NSG vs WAF

```
Internet Traffic → [WAF] → [Azure Firewall] → [NSG] → [VM/App]

┌─────────────────────────────────────────────────────────────────┐
│ WAF (Web Application Firewall)                                   │
│ - Layer 7 (HTTP/HTTPS only)                                      │
│ - Protects against: SQL injection, XSS, OWASP Top 10            │
│ - Attached to: Application Gateway or Front Door                 │
│ - Cost: ~$0.07/hour                                              │
├─────────────────────────────────────────────────────────────────┤
│ Azure Firewall                                                   │
│ - Layer 3-7 (all traffic)                                        │
│ - Central firewall for entire VNet                               │
│ - Features: FQDN filtering, threat intel, TLS inspection         │
│ - Cost: ~$0.13/hour + data processing                            │
├─────────────────────────────────────────────────────────────────┤
│ NSG (Network Security Group)                                     │
│ - Layer 3-4 (IP + Port only)                                     │
│ - Per-subnet or per-NIC                                          │
│ - Simple allow/deny rules                                        │
│ - Cost: FREE!                                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌍 Azure Front Door vs Traffic Manager vs Load Balancer

```
Global traffic distribution:
┌───────────────────────────────────────────────────────────────────┐
│                                                                    │
│  Azure Front Door (Global L7)                                      │
│  ├─ Global HTTP/HTTPS load balancing                              │
│  ├─ SSL offloading, WAF, caching                                  │
│  ├─ URL-path based routing                                        │
│  └─ Cost: ~$0.04/hour + per request                              │
│                                                                    │
│  Traffic Manager (Global DNS)                                      │
│  ├─ DNS-based routing (returns nearest IP)                        │
│  ├─ Methods: Priority, Weighted, Performance, Geographic          │
│  ├─ Works with ANY endpoint (Azure, on-prem, other clouds)       │
│  └─ Cost: ~$0.54 per million queries                             │
│                                                                    │
│  Application Gateway (Regional L7)                                 │
│  ├─ Regional HTTP load balancer + WAF                             │
│  ├─ URL routing, SSL termination, session affinity               │
│  └─ Cost: ~$0.07/hour                                            │
│                                                                    │
│  Load Balancer (Regional L4)                                       │
│  ├─ TCP/UDP load balancing (non-HTTP)                             │
│  ├─ Internal or Public                                            │
│  └─ Cost: ~$0.03/hour (Standard)                                 │
│                                                                    │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🏠 Hub-Spoke Network Architecture (Enterprise Pattern)

```
                    ┌─────────────────────────┐
                    │      HUB VNet           │
                    │                         │
                    │  [Azure Firewall]       │
                    │  [VPN Gateway]          │
                    │  [ExpressRoute GW]      │
                    │  [Bastion]              │
                    │  [DNS Servers]          │
                    └────┬──────┬──────┬─────┘
                         │      │      │
                Peering  │      │      │  Peering
                         │      │      │
          ┌──────────────┘      │      └──────────────┐
          │                     │                     │
          ▼                     ▼                     ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ SPOKE 1 (Prod)  │  │ SPOKE 2 (Dev)   │  │ SPOKE 3 (Data)  │
│                 │  │                 │  │                 │
│ [App VMs]       │  │ [Dev VMs]       │  │ [SQL Servers]   │
│ [AKS Cluster]   │  │ [Testing]       │  │ [Analytics]     │
│ [App Service]   │  │                 │  │ [Data Lake]     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Why Hub-Spoke:
- **Central security:** All traffic goes through Hub firewall
- **Shared services:** VPN/ExpressRoute in Hub only (saves money)
- **Isolation:** Spokes can't talk to each other directly (unless you allow)
- **Scalable:** Add new spokes without changing Hub

### CLI Setup:
```bash
# Create Hub VNet
az network vnet create -n hub-vnet -g network-rg --address-prefix 10.0.0.0/16

# Create Spoke VNet
az network vnet create -n spoke1-vnet -g spoke1-rg --address-prefix 10.1.0.0/16

# Peer Hub ↔ Spoke
az network vnet peering create \
  -n hub-to-spoke1 -g network-rg --vnet-name hub-vnet \
  --remote-vnet spoke1-vnet --allow-forwarded-traffic --allow-gateway-transit

az network vnet peering create \
  -n spoke1-to-hub -g spoke1-rg --vnet-name spoke1-vnet \
  --remote-vnet hub-vnet --allow-forwarded-traffic --use-remote-gateways
```

---

## 📖 Networking Reference
- VNet docs: https://learn.microsoft.com/en-us/azure/virtual-network/
- VPN Gateway: https://learn.microsoft.com/en-us/azure/vpn-gateway/
- ExpressRoute: https://learn.microsoft.com/en-us/azure/expressroute/
- Firewall: https://learn.microsoft.com/en-us/azure/firewall/
- Hub-Spoke: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke
