# 🔒 Azure VPN Setup - Complete Portal Step-by-Step Guide

> Every single click, every dropdown, every field — for Site-to-Site VPN, Point-to-Site VPN, and VPN Gateway configuration.

---

## Table of Contents
1. [Create a VPN Gateway](#1-create-a-vpn-gateway)
2. [Create a Local Network Gateway (On-Premises Representation)](#2-create-a-local-network-gateway)
3. [Create a Site-to-Site VPN Connection](#3-create-site-to-site-vpn-connection)
4. [Configure Point-to-Site VPN (Remote Users)](#4-configure-point-to-site-vpn)
5. [Download and Install VPN Client](#5-download-vpn-client)
6. [Monitor VPN Connections](#6-monitor-vpn-connections)
7. [Configure BGP (Border Gateway Protocol)](#7-configure-bgp)
8. [High Availability VPN (Active-Active)](#8-high-availability-vpn)
9. [Troubleshooting & Common Mistakes](#9-troubleshooting)

---

## 1. Create a VPN Gateway

### Prerequisites
```
Before creating a VPN Gateway, you MUST have:
✅ A Virtual Network (VNet) already created
✅ A subnet named EXACTLY "GatewaySubnet" (minimum /27)
   - Go to VNet → Subnets → + Gateway subnet
   - Azure auto-names it "GatewaySubnet"
   - Recommended: /27 (32 addresses) for future growth
```

### Step-by-Step

**Step 1: Navigate to Virtual Network Gateways**
```
1. Search bar → Type "Virtual network gateways"
2. Click "Virtual network gateways" from results
3. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Select/Enter                       │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Your subscription                          │
│ Name               │ hub-vpn-gateway                            │
│ Region             │ East US (MUST match your VNet region!)     │
│ Gateway type       │ "VPN" (not "ExpressRoute")                 │
│ SKU                │ VpnGw1 (options below)                     │
│ Generation         │ Generation2 (recommended)                  │
│ Virtual network    │ Select your VNet (e.g., hub-vnet)          │
│ Public IP address  │ "Create new"                               │
│ Public IP name     │ hub-vpn-gateway-pip                        │
│ Public IP SKU      │ Standard                                   │
│ Assignment         │ Static                                     │
│ Enable active-     │ "Disabled" (for basic setup)               │
│ active mode        │ "Enabled" (for HA — needs 2 public IPs)   │
│ Configure BGP      │ "Disabled" (enable if using BGP)           │
└─────────────────────────────────────────────────────────────────┘

VPN Gateway SKU Options:
┌──────────────────────────────────────────────────────────────┐
│ SKU       │ Tunnels │ Throughput │ P2S Connections │ Cost    │
├──────────────────────────────────────────────────────────────┤
│ VpnGw1    │ 30      │ 650 Mbps   │ 250             │ ~$140/mo│
│ VpnGw2    │ 30      │ 1 Gbps     │ 500             │ ~$360/mo│
│ VpnGw3    │ 30      │ 1.25 Gbps  │ 1000            │ ~$950/mo│
│ VpnGw4    │ 100     │ 5 Gbps     │ 5000            │ ~$1250  │
│ VpnGw5    │ 100     │ 10 Gbps    │ 10000           │ ~$2500  │
└──────────────────────────────────────────────────────────────┘
```

**Step 3: Review + Create**
```
1. Click "Review + create"
2. Click "Create"
3. ⏱️ IMPORTANT: VPN Gateway takes 30-45 MINUTES to deploy!
   - Don't wait at the screen
   - You'll get a notification when complete
   - Go do other tasks and come back
```

---

## 2. Create a Local Network Gateway

### What Is This?
The Local Network Gateway represents your ON-PREMISES network/device in Azure. It tells Azure:
- What is the public IP of your on-premises VPN device?
- What are the on-premises network ranges?

### Step-by-Step

**Step 1: Navigate**
```
1. Search bar → "Local network gateways"
2. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Subscription       │ Your subscription                          │
│ Resource group     │ networking-rg                              │
│ Region             │ East US (match VPN Gateway region)         │
│ Name               │ onprem-local-gateway                       │
│ Endpoint           │ "IP address" (or "FQDN" if IP changes)    │
│ IP address         │ 203.0.113.50 (your on-prem VPN device     │
│                    │ public IP)                                  │
│ Address Space(s)   │ Click "+ Add address range"                │
│                    │ 192.168.1.0/24 (your on-prem LAN)         │
│                    │ 192.168.2.0/24 (another on-prem subnet)   │
│                    │ 172.16.0.0/16 (if you have more)          │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Advanced Tab (BGP - Optional)**
```
┌─────────────────────────────────────────────────────────────────┐
│ Configure BGP settings │ "No" (default)                         │
│                        │ "Yes" if using BGP:                    │
│   ASN                  │ 65010 (your on-prem router's ASN)      │
│   BGP peer IP address  │ 192.168.1.1 (on-prem BGP peer)        │
└─────────────────────────────────────────────────────────────────┘

Click "Review + create" → "Create"
```

---

## 3. Create Site-to-Site VPN Connection

### What You'll Accomplish
Connect your on-premises network to Azure over an IPsec/IKE VPN tunnel.

### Prerequisites
```
✅ VPN Gateway deployed and running (status: Succeeded)
✅ Local Network Gateway created
✅ On-premises VPN device configured and accessible
```

### Step-by-Step

**Step 1: Navigate to Your VPN Gateway**
```
1. Search bar → "Virtual network gateways"
2. Click on your VPN gateway (e.g., "hub-vpn-gateway")
3. Left menu → "Connections"
4. Click "+ Add"
```

**Step 2: Fill in Connection Details**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                  │ What to Enter                          │
├─────────────────────────────────────────────────────────────────┤
│ Name                   │ azure-to-onprem-s2s                    │
│ Connection type        │ "Site-to-site (IPsec)" (dropdown)      │
│                        │ Options: VNet-to-VNet, Site-to-site,   │
│                        │ ExpressRoute                           │
│ Virtual network        │ hub-vpn-gateway (auto-selected)        │
│ gateway                │                                        │
│ Local network gateway  │ Select "onprem-local-gateway"          │
│ Shared key (PSK)       │ MyStr0ngPr3Sh4r3dK3y!2024             │
│                        │ ⚠️ MUST match on-prem device config!  │
│                        │ Use 32+ character random string        │
│ IKE Protocol           │ IKEv2 (recommended) or IKEv1          │
│ Enable BGP             │ Unchecked (unless using BGP)           │
│ Use Azure Private IP   │ Unchecked                              │
│ Address                │                                        │
│ Enable Custom BGP      │ Unchecked                              │
│ Addresses              │                                        │
│ FastPath               │ Unchecked                              │
│ Ingress NAT Rules      │ None                                   │
│ Egress NAT Rules       │ None                                   │
└─────────────────────────────────────────────────────────────────┘

Click "OK" or "Create"
```

**Step 3: Configure Your On-Premises VPN Device**
```
After creating the connection, you need to configure your on-prem device.

Get the configuration:
1. Go to VPN Gateway → Connections → Click your connection
2. Click "Download configuration" at the top
3. Select your device:
   - Vendor: Cisco / Juniper / Fortinet / Generic / etc.
   - Device family: ISR / ASA / FortiGate / etc.
   - Firmware version: Choose yours
4. Click "Download"
5. You'll get a text file with EXACT commands for your device

Key settings your on-prem device needs:
- Azure VPN Gateway Public IP: (shown in gateway overview)
- Pre-shared Key: MyStr0ngPr3Sh4r3dK3y!2024
- Azure VNet address space: 10.0.0.0/16
- IKE version: IKEv2
- IPsec encryption: AES256
- IPsec integrity: SHA256
- DH Group: DHGroup14 or ECP384
```

**Step 4: Verify Connection Status**
```
1. VPN Gateway → Connections
2. Check "Status" column:
   - "Connected" ✅ = Tunnel is up!
   - "Connecting" ⏳ = Still negotiating
   - "Unknown" ❓ = Check on-prem device
   - "Not connected" ❌ = Tunnel failed

If "Not connected" for >5 minutes:
1. Verify on-prem device public IP is correct
2. Verify pre-shared key matches EXACTLY (case-sensitive!)
3. Verify on-prem firewall allows UDP 500, UDP 4500
4. Check on-prem device logs
```

---

## 4. Configure Point-to-Site VPN

### What You'll Accomplish
Allow individual users/laptops to connect to Azure VNet from anywhere.

### Step-by-Step

**Step 1: Navigate to VPN Gateway Configuration**
```
1. Go to your VPN Gateway
2. Left menu → "Point-to-site configuration"
3. Click "Configure now" (if first time)
```

**Step 2: Configure Address Pool**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                  │ What to Enter                          │
├─────────────────────────────────────────────────────────────────┤
│ Address pool           │ 172.16.0.0/24                          │
│                        │ (Private range for VPN clients)        │
│                        │ ⚠️ CANNOT overlap with VNet or         │
│                        │ on-prem ranges!                        │
│ Tunnel type            │ "OpenVPN (SSL)" ← Recommended!        │
│                        │ "IKEv2" (native Windows)               │
│                        │ "SSTP" (Windows only, TCP 443)         │
│                        │ "IKEv2 and OpenVPN" (both)             │
│ Authentication type    │ Choose one:                            │
│                        │ ○ Azure certificate                    │
│                        │ ○ RADIUS authentication                │
│                        │ ● Azure Active Directory ← Best!      │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Configure Azure AD Authentication (Recommended)**
```
If you selected "Azure Active Directory":
┌─────────────────────────────────────────────────────────────────┐
│ Field          │ What to Enter                                  │
├─────────────────────────────────────────────────────────────────┤
│ Tenant         │ https://login.microsoftonline.com/YOUR-TENANT-ID/│
│ Audience       │ 41b23e61-6c1e-4545-b367-cd054e0ed4b4          │
│                │ (This is the Azure VPN Enterprise App ID)       │
│ Issuer         │ https://sts.windows.net/YOUR-TENANT-ID/        │
└─────────────────────────────────────────────────────────────────┘

Before this works, you must:
1. Go to Entra ID → Enterprise Applications
2. Search for "Azure VPN" 
3. If not found → "+ New application" → Search "Azure VPN" → Add
4. Grant admin consent for your tenant
```

**Step 4: Configure Certificate Authentication (Alternative)**
```
If you selected "Azure certificate":

Generate Root Certificate (on your PC — PowerShell):
─────────────────────────────────────────────────────
$cert = New-SelfSignedCertificate -Type Custom `
  -KeySpec Signature `
  -Subject "CN=VPNRootCert" `
  -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -KeyUsageProperty Sign `
  -KeyUsage CertSign

Export public key as Base64 .cer:
1. Open certmgr (Windows) → Personal → Certificates
2. Right-click VPNRootCert → All Tasks → Export
3. "No, do not export private key" → Base64 → Save as root.cer
4. Open root.cer in Notepad → Copy text between BEGIN/END markers

In Azure Portal:
┌─────────────────────────────────────────────────────────────────┐
│ Root certificates:                                              │
│ Name: VPNRootCert                                               │
│ Public certificate data: (paste the Base64 text here)           │
│                                                                 │
│ Revoked certificates: (add client certs to block)               │
└─────────────────────────────────────────────────────────────────┘
```

**Step 5: Save Configuration**
```
1. Click "Save" at the top of the page
2. ⏱️ Takes 5-10 minutes to update the gateway
3. Wait for "Succeeded" notification
```

---

## 5. Download VPN Client

### Step-by-Step

**Step 1: Download Client Package**
```
1. VPN Gateway → Point-to-site configuration
2. Click "Download VPN client" at the top
3. A .zip file downloads containing:
   - OpenVPN/ folder (for OpenVPN client)
   - WindowsAmd64/ (for native Windows IKEv2)
   - AzureVPN/ (for Azure VPN Client app)
   - Generic/ folder (contains VpnSettings.xml)
```

**Step 2: Install Azure VPN Client (Recommended)**
```
For Windows:
1. Install "Azure VPN Client" from Microsoft Store
2. Open it → Click "+" → "Import"
3. Browse to downloaded folder → AzureVPN → azurevpnconfig.xml
4. Click "Save"
5. Click "Connect"
6. Sign in with Azure AD credentials (if using AAD auth)
7. ✅ Connected! You now have a private IP in 172.16.0.x range

For macOS:
1. Install "Azure VPN Client" from App Store
2. Same import process as Windows

For Linux (OpenVPN):
1. Install openvpn: sudo apt install openvpn
2. Use the .ovpn file from OpenVPN/ folder
3. sudo openvpn --config azurevpnconfig.ovpn
```

**Step 3: Verify Connection**
```
Once connected:
1. Open terminal/PowerShell
2. ipconfig (Windows) or ifconfig (Linux/Mac)
3. You'll see a new adapter with IP: 172.16.0.2 (or similar)
4. Try: ping 10.0.1.4 (a VM in your VNet)
5. If ping works → ✅ VPN is functioning!
```

---

## 6. Monitor VPN Connections

### Site-to-Site Monitoring

**Step 1: Connection Status**
```
1. VPN Gateway → Connections → Click your S2S connection
2. Overview shows:
   - Status: Connected/Not connected
   - Data in: XX MB
   - Data out: XX MB
   - Connected since: timestamp
```

**Step 2: Metrics**
```
1. VPN Gateway → Left menu → "Metrics"
2. Useful metrics to monitor:
   - Tunnel Bandwidth: Throughput in bits/sec
   - Tunnel Egress Bytes: Data sent to on-prem
   - Tunnel Ingress Bytes: Data received from on-prem
   - Tunnel Egress Packet Drop Count: Packets lost
   - P2S Connection Count: Active P2S users
   - Gateway S2S Bandwidth: Overall S2S throughput
```

**Step 3: Diagnostic Logs**
```
1. VPN Gateway → Left menu → "Diagnostic settings"
2. Click "+ Add diagnostic setting"
3. Configure:
   - Name: vpn-diagnostics
   - Logs: Check ALL:
     ☑ GatewayDiagnosticLog
     ☑ TunnelDiagnosticLog
     ☑ RouteDiagnosticLog
     ☑ IKEDiagnosticLog
     ☑ P2SDiagnosticLog
   - Destination:
     ☑ Send to Log Analytics workspace → Select workspace
4. Click "Save"
```

**Step 4: View Logs**
```
1. Go to Log Analytics workspace
2. Left menu → "Logs"
3. Query example:
   AzureDiagnostics
   | where ResourceType == "VIRTUALNETWORKGATEWAYS"
   | where Category == "TunnelDiagnosticLog"
   | where TimeGenerated > ago(1h)
   | project TimeGenerated, status_s, remoteIP_s, stateChangeReason_s
   | order by TimeGenerated desc
```

---

## 7. Configure BGP

### When to Use BGP
```
- Multiple on-prem sites with complex routing
- Automatic route propagation (no manual route updates)
- Active-active gateway setups
- Transit routing between VNets and on-prem
```

### Step-by-Step

**Step 1: Enable BGP on VPN Gateway (during creation)**
```
When creating VPN Gateway:
- Configure BGP: "Enabled"
- ASN: 65515 (default Azure ASN, or choose custom: 65000-65534)
- Custom Azure APIPA BGP IP address: leave blank (auto-assigned)
```

**Step 2: Enable BGP on Local Network Gateway**
```
1. Local Network Gateway → Left menu → "Configuration"
2. Configure BGP settings: "Yes"
3. Fill in:
   - ASN: 65010 (your on-prem router's ASN)
   - BGP peer IP address: 192.168.1.1 (on-prem BGP speaker IP)
4. Click "Save"
```

**Step 3: Enable BGP on Connection**
```
1. VPN Gateway → Connections → Click your connection
2. Left menu → "Configuration"
3. Enable BGP: ☑ Checked
4. Click "Save"
```

**Step 4: Verify BGP**
```
1. VPN Gateway → Left menu → "BGP peers"
2. You'll see:
   │ Peer │ ASN │ Status │ Routes received │
   │ 192.168.1.1 │ 65010 │ Connected │ 5 │

3. Click "Learned routes" to see what Azure learned from on-prem
4. Click "Advertised routes" to see what Azure sends to on-prem
```

---

## 8. High Availability VPN

### Active-Active Configuration

**What is it?**
```
Instead of one VPN gateway instance:
- Two instances, each with its own public IP
- Both tunnels active simultaneously
- On-prem connects to BOTH IPs
- If one fails, traffic flows through the other
- No failover delay!
```

**Step 1: Create Active-Active Gateway**
```
During VPN Gateway creation:
1. Enable active-active mode: "Enabled"
2. First public IP address: Create new → "vpn-gw-pip-1"
3. Second public IP address: Create new → "vpn-gw-pip-2"

⚠️ Cannot change existing gateway to active-active without recreation!
   (Actually you CAN for some SKUs — check gateway → Configuration)
```

**Step 2: Configure Two Connections**
```
On-prem device needs TWO tunnels:
- Tunnel 1: On-prem → Azure Public IP 1
- Tunnel 2: On-prem → Azure Public IP 2

In Azure, create TWO connections:
1. Connection 1: vpn-gw-pip-1 ↔ on-prem (same shared key)
2. Connection 2: vpn-gw-pip-2 ↔ on-prem (same shared key)

On-prem device: Configure ECMP (Equal-Cost Multi-Path) to use both
```

### Zone-Redundant Gateway
```
For even higher availability:
1. When creating gateway, select SKU: VpnGw1AZ (note the "AZ")
2. This deploys gateway across availability zones
3. Survives entire datacenter failure within a region
4. Public IP MUST be Standard SKU + Zone-redundant
```

---

## 9. Troubleshooting

### ❌ Mistake 1: S2S Tunnel Won't Connect
```
Problem: Status stays "Not connected" or "Connecting" forever

Checklist:
1. Pre-shared key MUST match EXACTLY (case-sensitive!)
   - Azure side: Connection → Properties → Shared key
   - On-prem: Check device config

2. On-prem firewall must allow:
   - UDP port 500 (IKE negotiation)
   - UDP port 4500 (NAT traversal)
   - IP Protocol 50 (ESP) — if no NAT

3. IKE version must match:
   - Azure: Connection → Configuration → IKE protocol
   - On-prem: Must use same version

4. On-prem public IP must be correct:
   - Local Network Gateway → Configuration → IP address
   - Must be the ACTUAL public IP of on-prem device

5. Address spaces must not overlap:
   - Azure VNet: 10.0.0.0/16
   - On-prem (in Local GW): 192.168.0.0/16
   - These CANNOT overlap!

Diagnostic tool:
1. VPN Gateway → Left menu → "VPN troubleshoot"
2. Select the connection
3. Select storage account for results
4. Click "Start troubleshooting"
5. Wait 2-5 minutes → Read results
```

### ❌ Mistake 2: P2S Users Can't Connect
```
Problem: Azure VPN Client shows "Connection failed"

Checklist:
1. VPN client address pool doesn't overlap with VNet:
   - VNet: 10.0.0.0/16
   - P2S pool: 172.16.0.0/24 ✅ (different range)

2. Root certificate uploaded correctly:
   - Must be Base64 encoded (not DER)
   - Must be ROOT cert (not client cert)
   - No BEGIN/END markers in the portal field

3. Client certificate is valid:
   - Generated from the SAME root cert uploaded to Azure
   - Installed in Current User\Personal\Certificates
   - Not expired

4. Azure AD auth:
   - Enterprise app "Azure VPN" must be added
   - Admin consent granted
   - User is assigned to the app

5. Re-download VPN client after config changes:
   - Any change to P2S config = must download new client profile
```

### ❌ Mistake 3: Connected but Can't Reach Resources
```
Problem: VPN shows "Connected" but can't ping VMs

Checklist:
1. NSG on target VM allows traffic from VPN client range:
   - Source: 172.16.0.0/24 (P2S pool) or 192.168.0.0/16 (S2S)
   - Must have inbound rule allowing the traffic

2. Route propagation:
   - VNet → Subnets → Check "Propagate gateway routes": Enabled
   - If using custom route table, ensure it has VPN routes

3. VM firewall (Windows):
   - Windows Firewall might block ICMP/pings
   - RDP into VM and check Windows Firewall rules

4. For S2S: On-prem device has return route to Azure:
   - On-prem must know to route 10.0.0.0/16 → VPN tunnel
   - Check on-prem routing table
```

### ❌ Mistake 4: GatewaySubnet Missing or Wrong Size
```
Problem: Can't create VPN Gateway — "No GatewaySubnet found"

Fix:
1. Go to your VNet → Subnets
2. Click "+ Gateway subnet" (special button, NOT regular "+ Subnet")
3. Azure auto-names it "GatewaySubnet" (CANNOT change the name!)
4. Address range: /27 minimum (32 IPs)
   - Recommended: /27 for basic, /26 for active-active
5. DON'T associate an NSG with GatewaySubnet!
6. Click "Save"
```

### ❌ Mistake 5: VPN Gateway Taking Forever to Deploy
```
This is NORMAL behavior:
- VPN Gateway deployment: 30-45 minutes
- Don't delete and recreate (resets the timer!)
- Check: Resource group → Deployments → See progress

If stuck >60 minutes:
1. Check resource group → Deployments → Click the deployment
2. Look for error messages
3. Common cause: GatewaySubnet too small or address conflict
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create VPN Gateway | Virtual network gateways → + Create |
| Create Local GW | Local network gateways → + Create |
| Create S2S Connection | VPN Gateway → Connections → + Add |
| Configure P2S | VPN Gateway → Point-to-site configuration |
| Download VPN Client | P2S config page → Download VPN client |
| Monitor Tunnels | VPN Gateway → Connections → Status |
| View Metrics | VPN Gateway → Metrics |
| Troubleshoot | VPN Gateway → VPN troubleshoot |
| BGP Peers | VPN Gateway → BGP peers |
| Gateway Subnet | VNet → Subnets → + Gateway subnet |

---

## 📊 Cost Awareness

```
⚠️ VPN Gateways charge PER HOUR even when no tunnels are active!

VpnGw1: ~$0.19/hr = ~$140/month
VpnGw2: ~$0.49/hr = ~$360/month
VpnGw3: ~$1.30/hr = ~$950/month

Data transfer: Additional ~$0.035-0.09/GB outbound

For lab/testing: Delete the gateway when done!
VPN Gateway → Overview → Delete
(Takes ~15 minutes to delete)
```

---

## 🔗 Related Labs
- [Lab 15: VPN Gateway Disconnected](../lab-15-vpn-gateway-disconnected/)
- [Lab 09: VNet No Internet](../lab-09-vnet-no-internet/)
- [Lab 11: VNet Peering Broken](../lab-11-vnet-peering-broken/)
- [Lab 16: Azure Firewall Blocking](../lab-16-azure-firewall-blocking/)
