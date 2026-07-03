# 🌐 Azure Networking - Complete Portal Step-by-Step Guide

> Every single click, every field, every screen — for VNet, Subnets, NSG, Peering, and DNS.

---

## Table of Contents
1. [Create a Virtual Network (VNet)](#1-create-a-virtual-network)
2. [Add Subnets to a VNet](#2-add-subnets)
3. [Create a Network Security Group (NSG)](#3-create-a-network-security-group)
4. [Add NSG Rules (Allow/Deny Traffic)](#4-add-nsg-rules)
5. [Associate NSG with Subnet or NIC](#5-associate-nsg)
6. [Create VNet Peering](#6-create-vnet-peering)
7. [Create a Public IP Address](#7-create-a-public-ip)
8. [Configure DNS Zones](#8-configure-dns-zones)
9. [Create a Private Endpoint](#9-create-a-private-endpoint)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Create a Virtual Network

### What You'll Accomplish
Create an isolated network in Azure where your VMs and services communicate.

### Step-by-Step

**Step 1: Navigate to Virtual Networks**
```
1. Open https://portal.azure.com
2. In the top search bar, type: "Virtual networks"
3. Click "Virtual networks" from the results
4. Click "+ Create" button at the top
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Select your subscription from dropdown     │
│ Resource group     │ Select existing or click "Create new"      │
│                    │ → Name: "networking-rg" → OK               │
│ Virtual network    │ my-app-vnet                                │
│ name               │                                            │
│ Region             │ East US (or your preferred region)         │
│                    │ ⚠️ Must match region of resources using it │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Security"
```

**Step 3: Security Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Azure Bastion            │ ☐ Disabled (default)                 │
│                          │ Enable if you need secure VM access  │
│ Azure Firewall           │ ☐ Disabled (default)                 │
│                          │ Enable for centralized firewall      │
│ Azure DDoS Network       │ ☐ Disabled (default)                 │
│ Protection               │ Enable for production workloads      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: IP Addresses"
```

**Step 4: IP Addresses Tab**
```
This is the MOST IMPORTANT tab!

Default address space shown: 10.0.0.0/16
(This gives you 65,536 IP addresses)

You'll see a default subnet already listed:
  default | 10.0.0.0/24 (256 addresses)

To EDIT the address space:
1. Click on "10.0.0.0/16" in the address space box
2. Modify if needed (e.g., 10.1.0.0/16 to avoid conflicts)

To ADD a subnet:
1. Click "+ Add a subnet"
2. A panel opens on the right:
   ┌──────────────────────────────────────────────────────────┐
   │ Subnet template    │ Default (or choose Gateway, etc.)   │
   │ Name               │ web-subnet                          │
   │ Starting address   │ 10.0.1.0                            │
   │ Subnet size        │ /24 (256 addresses)                 │
   │                    │ /25 (128), /26 (64), /27 (32)       │
   │ NAT gateway        │ None (or select existing)           │
   │ Network security   │ None (attach later)                 │
   │ group              │                                     │
   │ Route table        │ None (attach later)                 │
   └──────────────────────────────────────────────────────────┘
3. Click "Add"

Recommended subnet layout:
  - web-subnet:    10.0.1.0/24 (for web servers)
  - app-subnet:    10.0.2.0/24 (for app tier)
  - db-subnet:     10.0.3.0/24 (for databases)
  - AzureBastionSubnet: 10.0.255.0/26 (if using Bastion, MUST use this name)
```

**Step 5: Tags Tab**
```
1. Click "Next: Tags"
2. Add tags:
   - Name: Environment  Value: Production
   - Name: Project      Value: MyApp
```

**Step 6: Review + Create**
```
1. Click "Review + create"
2. Validation will run (green checkmark = good)
3. Review summary:
   - Address space: 10.0.0.0/16
   - Subnets: default, web-subnet, app-subnet, db-subnet
4. Click "Create"
5. ✅ "Deployment complete" — Click "Go to resource"
```

---

## 2. Add Subnets

### Add a Subnet to an Existing VNet

**Step 1: Open VNet Settings**
```
1. Go to your VNet (search "Virtual networks" → click your VNet)
2. In the LEFT menu under "Settings", click "Subnets"
   → You'll see all existing subnets listed
```

**Step 2: Add New Subnet**
```
1. Click "+ Subnet" at the top
2. A panel opens on the right:
   ┌──────────────────────────────────────────────────────────┐
   │ Name                     │ api-subnet                    │
   │ Subnet address range     │ 10.0.4.0/24                   │
   │                          │                               │
   │ NAT Gateway              │ None (dropdown)               │
   │ Network security group   │ None or select existing       │
   │ Route table              │ None or select existing       │
   │                          │                               │
   │ SERVICE ENDPOINTS:       │                               │
   │ Services                 │ Click dropdown to add:        │
   │                          │ □ Microsoft.Storage           │
   │                          │ □ Microsoft.Sql               │
   │                          │ □ Microsoft.KeyVault          │
   │                          │ □ Microsoft.Web               │
   │                          │                               │
   │ SUBNET DELEGATION:       │                               │
   │ Delegate subnet to       │ None (or choose a service)    │
   │ a service                │ e.g., Microsoft.Web/serverFarms│
   │                          │ (locks subnet to that service)│
   │                          │                               │
   │ PRIVATE ENDPOINT         │                               │
   │ NETWORK POLICY:          │                               │
   │ Network policy for       │ Disabled / Enabled            │
   │ private endpoints        │                               │
   └──────────────────────────────────────────────────────────┘
3. Click "Save" (or "Add")
4. ✅ Subnet appears in the list
```

### Special Subnet Names (Azure Requires Exact Names)
```
- AzureBastionSubnet     → /26 minimum, for Azure Bastion
- GatewaySubnet          → /27 minimum, for VPN/ExpressRoute Gateway
- AzureFirewallSubnet    → /26 minimum, for Azure Firewall
- RouteServerSubnet      → /27 minimum, for Route Server
```

---

## 3. Create a Network Security Group

### What You'll Accomplish
Create an NSG (virtual firewall) to control traffic to/from subnets or NICs.

### Step-by-Step

**Step 1: Navigate to NSGs**
```
1. Search bar → Type "Network security groups"
2. Click "Network security groups" from results
3. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Select your subscription                   │
│ Resource group     │ networking-rg (same as VNet)               │
│ Name               │ web-subnet-nsg                             │
│ Region             │ East US (MUST match VNet region!)          │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Tags + Create**
```
1. Click "Next: Tags" → Add tags if needed
2. Click "Review + create"
3. Click "Create"
4. ✅ NSG created
```

**Default Rules (automatically created):**
```
INBOUND:
  Priority 65000: AllowVnetInBound (VNet ↔ VNet traffic)
  Priority 65001: AllowAzureLoadBalancerInBound
  Priority 65500: DenyAllInBound (blocks everything else)

OUTBOUND:
  Priority 65000: AllowVnetOutBound
  Priority 65001: AllowInternetOutBound
  Priority 65500: DenyAllOutBound
```

---

## 4. Add NSG Rules

### Add an Inbound Rule (Allow HTTP)

**Step 1: Open NSG**
```
1. Go to your NSG (click on "web-subnet-nsg")
2. Left menu → "Inbound security rules"
3. Click "+ Add"
```

**Step 2: Fill in the Rule**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                │ What to Enter                            │
├─────────────────────────────────────────────────────────────────┤
│ Source               │ "Any" (dropdown options: Any, IP         │
│                      │ addresses, Service Tag, ASG)             │
│ Source port ranges   │ * (means all source ports)               │
│ Destination          │ "Any" (or specific IP/Service Tag)       │
│ Destination port     │ 80 (for HTTP)                            │
│ ranges              │ Or: 80,443 (comma-separated)             │
│                      │ Or: 8080-8090 (range)                    │
│ Protocol             │ "TCP" (dropdown: Any, TCP, UDP, ICMP)    │
│ Action               │ "Allow" (radio: Allow / Deny)            │
│ Priority             │ 100 (lower number = higher priority)     │
│                      │ Range: 100-4096                          │
│ Name                 │ Allow-HTTP-Inbound                       │
│ Description          │ Allow HTTP traffic from internet         │
└─────────────────────────────────────────────────────────────────┘

Click "Add"
✅ Rule appears in the inbound rules list
```

### Add HTTPS Rule
```
Same as above but:
- Destination port ranges: 443
- Priority: 110
- Name: Allow-HTTPS-Inbound
```

### Add SSH Rule (Restrict to Your IP!)
```
- Source: "IP Addresses"
- Source IP addresses: YOUR.PUBLIC.IP/32
  (Find your IP at https://whatismyip.com)
- Destination port ranges: 22
- Protocol: TCP
- Action: Allow
- Priority: 120
- Name: Allow-SSH-FromMyIP

⚠️ NEVER set Source to "Any" for SSH/RDP!
```

### Add a Deny Rule (Block Specific Traffic)
```
- Source: IP Addresses → 10.0.2.0/24
- Destination port ranges: 3306
- Protocol: TCP
- Action: Deny
- Priority: 200
- Name: Deny-MySQL-FromAppSubnet
```

---

## 5. Associate NSG

### Associate NSG with a Subnet

**Step 1: From NSG Side**
```
1. Open your NSG → Left menu → "Subnets"
2. Click "+ Associate"
3. Panel opens:
   - Virtual network: Select "my-app-vnet" (dropdown)
   - Subnet: Select "web-subnet" (dropdown)
4. Click "OK"
5. ✅ NSG is now protecting all resources in that subnet
```

**Step 2: From VNet Side (Alternative)**
```
1. Open your VNet → Left menu → "Subnets"
2. Click on the subnet name (e.g., "web-subnet")
3. In the subnet panel:
   - Network security group: Select "web-subnet-nsg" (dropdown)
4. Click "Save"
```

### Associate NSG with a NIC (Network Interface)

```
1. Open your NSG → Left menu → "Network interfaces"
2. Click "+ Associate"
3. Select the NIC from the dropdown
   (NIC names look like: my-vm-nic or my-vm123)
4. Click "OK"

⚠️ If BOTH subnet NSG and NIC NSG exist:
   - Inbound: Subnet NSG checked FIRST, then NIC NSG
   - Outbound: NIC NSG checked FIRST, then Subnet NSG
   - Traffic must be ALLOWED by BOTH to pass
```

---

## 6. Create VNet Peering

### What You'll Accomplish
Connect two VNets so resources can communicate across them.

### Step-by-Step

**Step 1: Open Source VNet**
```
1. Go to "Virtual networks" → Click on VNet-A (e.g., "hub-vnet")
2. Left menu → "Peerings"
3. Click "+ Add"
```

**Step 2: Configure Peering**
```
This VNet (local) peering settings:
┌─────────────────────────────────────────────────────────────────┐
│ Field                          │ What to Enter                  │
├─────────────────────────────────────────────────────────────────┤
│ Peering link name              │ hub-to-spoke1                  │
│ Traffic to remote VNet         │ "Allow" (default)              │
│ Traffic forwarded from remote  │ "Block" or "Allow"             │
│ VNet                           │ (Allow if hub is a firewall)   │
│ Virtual network gateway or     │ "None" (or "Use this VNet's   │
│ Route Server                   │ gateway" if hub has VPN GW)    │
└─────────────────────────────────────────────────────────────────┘

Remote virtual network peering settings:
┌─────────────────────────────────────────────────────────────────┐
│ Peering link name              │ spoke1-to-hub                  │
│ Subscription                   │ Select (can be different sub!) │
│ Virtual network                │ spoke1-vnet                    │
│ Traffic to remote VNet         │ "Allow"                        │
│ Traffic forwarded from remote  │ "Allow" (to receive hub        │
│ VNet                           │ forwarded traffic)             │
│ Virtual network gateway or     │ "Use the remote VNet's        │
│ Route Server                   │ gateway" (if hub has GW)       │
└─────────────────────────────────────────────────────────────────┘

Click "Add"
✅ Both peering links created (one on each VNet)
```

**Step 3: Verify Peering Status**
```
1. After creation, check "Peering status" column:
   - "Connected" ✅ = Working
   - "Initiated" ⚠️ = Only one side configured (shouldn't happen via Portal)
   - "Disconnected" ❌ = Broken (address space conflict or deleted)

2. Both VNets' peering page should show "Connected"
```

### ⚠️ Peering Rules
```
- NOT transitive: VNet-A ↔ VNet-B and VNet-B ↔ VNet-C does NOT mean A ↔ C
- Address spaces CANNOT overlap (e.g., both can't use 10.0.0.0/16)
- Once peered, you CANNOT add overlapping address ranges
```

---

## 7. Create a Public IP

### Step-by-Step

**Step 1: Navigate**
```
1. Search bar → "Public IP addresses"
2. Click "+ Create"
```

**Step 2: Fill in Details**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ IP version         │ IPv4 (or IPv6, or Both)                    │
│ SKU                │ "Standard" (recommended — zone-redundant)  │
│                    │ "Basic" (legacy, being retired)            │
│ Tier               │ "Regional" (default)                       │
│ Name               │ my-app-public-ip                           │
│ IP address         │ "Static" ← Choose this for production!    │
│ assignment         │ "Dynamic" = changes on stop/start          │
│ Routing preference │ "Microsoft network" (default, lower        │
│                    │ latency) or "Internet"                     │
│ Idle timeout       │ 4 minutes (default, range 4-30)            │
│ DNS name label     │ my-app-eastus (creates                     │
│                    │ my-app-eastus.eastus.cloudapp.azure.com)    │
│ Subscription       │ Your subscription                          │
│ Resource group     │ networking-rg                              │
│ Region             │ East US                                    │
│ Availability zone  │ "Zone-redundant" (Standard SKU)            │
└─────────────────────────────────────────────────────────────────┘

Click "Create"
```

---

## 8. Configure DNS Zones

### Create a Public DNS Zone

**Step 1: Navigate**
```
1. Search bar → "DNS zones"
2. Click "+ Create"
```

**Step 2: Fill in Details**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Your subscription                          │
│ Resource group     │ networking-rg                              │
│ Name               │ myapp.com (your actual domain name)        │
│ Resource group     │ Same or different location                 │
│ location           │                                            │
└─────────────────────────────────────────────────────────────────┘

Click "Review + create" → "Create"
```

**Step 3: Add DNS Records**
```
1. Open your DNS zone → You'll see the record sets page
2. Click "+ Record set"
3. Panel opens:
   ┌──────────────────────────────────────────────────────────┐
   │ Name    │ www                                            │
   │ Type    │ A (dropdown: A, AAAA, CNAME, MX, TXT, etc.)  │
   │ TTL     │ 1 Hour (default)                              │
   │ IP addr │ 20.50.100.200 (your resource's public IP)     │
   └──────────────────────────────────────────────────────────┘
4. Click "OK"

Common record types:
- A record: www → 20.50.100.200 (domain to IP)
- CNAME: api → myapp.azurewebsites.net (domain to domain)
- TXT: @ → "v=spf1 include:..." (verification/email)
- MX: @ → mail.myapp.com (email routing)
```

**Step 4: Point Your Domain Registrar to Azure DNS**
```
After creating the zone, Azure shows NS records:
  ns1-01.azure-dns.com
  ns2-01.azure-dns.net
  ns3-01.azure-dns.org
  ns4-01.azure-dns.info

Go to your domain registrar (GoDaddy, Namecheap, etc.):
1. Find "Nameservers" or "DNS settings"
2. Change to "Custom nameservers"
3. Enter the 4 Azure NS records
4. Save (propagation takes 24-48 hours)
```

---

## 9. Create a Private Endpoint

### What You'll Accomplish
Access Azure PaaS services (Storage, SQL, Key Vault) over a private IP in your VNet.

### Step-by-Step

**Step 1: Navigate**
```
1. Search bar → "Private endpoints"
2. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Your subscription                          │
│ Resource group     │ networking-rg                              │
│ Name               │ storage-private-endpoint                   │
│ Network Interface  │ storage-private-endpoint-nic (auto)        │
│ Name               │                                            │
│ Region             │ East US (must match VNet region)           │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Resource"
```

**Step 3: Resource Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Connection method        │ "Connect to an Azure resource in     │
│                          │ my directory" (radio button)          │
│ Subscription             │ Your subscription                    │
│ Resource type            │ Microsoft.Storage/storageAccounts    │
│ Resource                 │ mystorageaccount (your storage)      │
│ Target sub-resource      │ "blob" (or: file, table, queue,     │
│                          │ web, dfs)                            │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Virtual Network"
```

**Step 4: Virtual Network Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Virtual network          │ my-app-vnet                          │
│ Subnet                   │ db-subnet (or any subnet)            │
│ Private IP configuration │ "Dynamically allocate IP" (default)  │
│                          │ or "Statically allocate IP"          │
│ Application security     │ None (optional)                      │
│ group                    │                                      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: DNS"
```

**Step 5: DNS Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Integrate with private DNS   │ "Yes" ← IMPORTANT!              │
│ zone                         │ (Creates DNS for private IP)     │
│ Subscription                 │ Your subscription                │
│ Resource group               │ networking-rg                    │
│ Private DNS zone             │ privatelink.blob.core.windows.net│
│                              │ (auto-suggested based on service)│
└─────────────────────────────────────────────────────────────────┘

⚠️ If you select "No", you must configure DNS manually!
   Without DNS, apps will still resolve to the public IP.

Click "Next: Tags" → "Review + create" → "Create"
```

---

## 10. Troubleshooting

### ❌ Mistake 1: NSG Blocking Traffic You Thought Was Allowed
```
Problem: VM can't receive traffic on port 443
Diagnosis:
1. Go to VM → Left menu → "Networking"
2. You'll see "Effective security rules" (combines subnet + NIC NSG)
3. Click "Effective security rules" tab
4. Look for your port — is it DENY before ALLOW?

Fix:
- Check Priority numbers (lower = evaluated first)
- A Deny at priority 200 blocks Allow at priority 300
- Move Allow to a LOWER number than any Deny
```

### ❌ Mistake 2: VNet Peering Shows "Disconnected"
```
Problem: Peered VNets can't communicate
Diagnosis:
1. VNet → Peerings → Check status
2. Common causes:
   - Address space was modified after peering
   - One side was deleted
   - Overlapping address ranges added

Fix:
1. Delete both peering links
2. Fix address space conflicts
3. Re-create the peering
```

### ❌ Mistake 3: VM Has No Internet Access
```
Problem: VM can't reach the internet
Diagnosis:
1. Check NSG outbound rules — is internet blocked?
2. Check Route Table — is there a 0.0.0.0/0 route to a firewall?
3. Check if subnet has a NAT Gateway (needed for outbound-only)

Fix:
1. NSG: Ensure "AllowInternetOutBound" (default) isn't overridden
2. Route: If UDR sends to firewall, ensure firewall allows traffic
3. Public IP: Attach a public IP or NAT Gateway for outbound
```

### ❌ Mistake 4: Private Endpoint Not Resolving
```
Problem: App still connects to public IP instead of private endpoint
Diagnosis:
1. nslookup mystorageaccount.blob.core.windows.net
2. Should return: mystorageaccount.privatelink.blob.core.windows.net → 10.0.3.4
3. If returns public IP → DNS not configured

Fix:
1. Check if Private DNS Zone exists (privatelink.blob.core.windows.net)
2. Check if DNS zone is linked to your VNet:
   DNS Zone → "Virtual network links" → Your VNet must be listed
3. If missing: "+ Add" → Select VNet → Enable auto-registration: No → OK
```

### ❌ Mistake 5: Peering Not Transitive
```
Problem: Spoke1 can reach Hub, Hub can reach Spoke2, but Spoke1 ↔ Spoke2 fails
Why: Peering is NOT transitive by default!

Fix options:
1. Hub-and-spoke with Azure Firewall/NVA:
   - Route Spoke1 traffic through Hub firewall to reach Spoke2
   - Enable "Allow forwarded traffic" on both peerings
2. VNet peering between Spoke1 and Spoke2 directly
3. Use Azure Virtual WAN (managed hub-and-spoke)
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create VNet | Virtual networks → + Create |
| Add Subnet | VNet → Subnets → + Subnet |
| Create NSG | Network security groups → + Create |
| Add NSG Rule | NSG → Inbound/Outbound rules → + Add |
| Associate NSG | NSG → Subnets → + Associate |
| Create Peering | VNet → Peerings → + Add |
| Public IP | Public IP addresses → + Create |
| DNS Zone | DNS zones → + Create |
| Private Endpoint | Private endpoints → + Create |
| Check Effective Rules | VM → Networking → Effective security rules |

---

## 🔗 Related Labs
- [Lab 09: VNet No Internet](../lab-09-vnet-no-internet/)
- [Lab 10: NSG Blocking Traffic](../lab-10-nsg-blocking-traffic/)
- [Lab 11: VNet Peering Broken](../lab-11-vnet-peering-broken/)
- [Lab 12: Private Endpoint DNS](../lab-12-private-endpoint-dns/)
- [Lab 13: Application Gateway 502](../lab-13-application-gateway-502/)
- [Lab 14: Load Balancer No Connectivity](../lab-14-load-balancer-no-connectivity/)
- [Lab 15: VPN Gateway Disconnected](../lab-15-vpn-gateway-disconnected/)
- [Lab 16: Azure Firewall Blocking](../lab-16-azure-firewall-blocking/)
- [Lab 17: DNS Zone Not Resolving](../lab-17-dns-zone-not-resolving/)
- [Lab 18: Front Door Routing Wrong](../lab-18-front-door-routing-wrong/)
