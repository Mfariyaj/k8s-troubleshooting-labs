# 🌍 Azure App Service - Complete Portal Step-by-Step Guide

> Every single click, every field — for creating, deploying, scaling, and configuring Azure App Service.

---

## Table of Contents
1. [Create an App Service (Web App)](#1-create-an-app-service)
2. [Deploy Code to App Service](#2-deploy-code)
3. [Configure Custom Domain](#3-configure-custom-domain)
4. [Enable SSL/TLS Certificate](#4-enable-ssl-certificate)
5. [Configure Application Settings & Connection Strings](#5-configure-app-settings)
6. [Set Up Deployment Slots (Staging)](#6-deployment-slots)
7. [Configure Autoscale](#7-configure-autoscale)
8. [VNet Integration](#8-vnet-integration)
9. [Configure Logging & Diagnostics](#9-configure-logging)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Create an App Service

### Step-by-Step

**Step 1: Navigate to App Services**
```
1. Open https://portal.azure.com
2. Search bar → Type "App Services"
3. Click "App Services" from results
4. Click "+ Create" → "Web App"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ Select existing or "Create new"      │
│                          │ → Name: "webapp-rg" → OK             │
│                          │                                      │
│ INSTANCE DETAILS:        │                                      │
│ Name                     │ my-awesome-app                       │
│                          │ (becomes my-awesome-app.azurewebsites│
│                          │ .net — must be globally unique!)      │
│ Publish                  │ "Code" (or "Docker Container"        │
│                          │ or "Static Web App")                 │
│ Runtime stack            │ ".NET 8 (LTS)" (dropdown options:)   │
│                          │ .NET 8, .NET 7, Java 17, Node 20,   │
│                          │ Python 3.12, PHP 8.3, Ruby           │
│ Operating System         │ "Linux" (cheaper, recommended)       │
│                          │ "Windows" (needed for .NET Framework)│
│ Region                   │ East US                              │
│                          │                                      │
│ PRICING PLAN:            │                                      │
│ Linux Plan               │ Select existing or "Create new"      │
│                          │ Name: "my-app-plan"                  │
│ Pricing plan             │ Click "Explore pricing plans"        │
│                          │ Options:                             │
│                          │ Free F1: $0/mo (dev/test, limited)   │
│                          │ Basic B1: ~$13/mo (custom domain)    │
│                          │ Standard S1: ~$70/mo (slots, scale)  │
│                          │ Premium P1v3: ~$138/mo (VNet, more)  │
│                          │ Select "Standard S1" for this guide  │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Database"
```

**Step 3: Database Tab (Optional)**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Enable database          │ ☐ Skip (configure later)             │
│                          │ ☑ Create + connect:                  │
│   Database engine        │ Azure SQL / PostgreSQL / MySQL       │
│   Server name            │ my-db-server                         │
│   Database name          │ myappdb                              │
│   Admin username         │ sqladmin                             │
│   Admin password         │ StrongP@ss123!                       │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Deployment"
```

**Step 4: Deployment Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Continuous deployment        │ ☐ Disable (deploy manually)      │
│                              │ ☑ Enable (auto-deploy from Git)  │
│                              │                                  │
│ If enabled:                  │                                  │
│ GitHub Actions settings:     │                                  │
│   GitHub account             │ Sign in → Authorize Azure        │
│   Organization               │ Your GitHub org/username         │
│   Repository                 │ Select your repo                 │
│   Branch                     │ main                             │
│                              │                                  │
│ Authentication type          │ "Basic authentication"           │
│                              │ OR "User-assigned identity"      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Networking"
```

**Step 5: Networking Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Enable public access         │ "On" (default — accessible from  │
│                              │ internet)                        │
│                              │ "Off" (private endpoint only)    │
│ Enable network injection     │ ☐ Off (default)                  │
│                              │ ☑ On (runs in your VNet)         │
│                              │ Requires Premium plan            │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Monitoring"
```

**Step 6: Monitoring Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Enable Application Insights  │ "Yes" (recommended!)             │
│ Application Insights         │ "Create new"                     │
│                              │ Name: my-awesome-app-insights    │
│                              │ Region: East US                  │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Tags" → Add tags → "Review + create" → "Create"
⏱️ Deployment takes 1-2 minutes
✅ Click "Go to resource"
```

---

## 2. Deploy Code

### Option A: Deploy from GitHub (CI/CD)

**Step 1: Set Up Deployment Center**
```
1. App Service → Left menu → "Deployment Center"
2. Source dropdown: Select "GitHub"
3. Click "Authorize" (if first time)
4. Configure:
   - Organization: YourGitHubUser
   - Repository: my-web-app
   - Branch: main
   - Workflow option: "Add a workflow"
   - Authentication: "Basic authentication"
5. Click "Save"

What happens:
- Azure creates a GitHub Actions workflow in your repo
- Every push to 'main' triggers deployment
- You can see deployment status in Deployment Center
```

**Step 2: Check Deployment Status**
```
1. Deployment Center → "Logs" tab
2. You'll see deployment history:
   │ Status │ Time │ Message │ Commit │
   │ ✅ Success │ 2min ago │ Deployed │ abc123 │
```

### Option B: Deploy ZIP File (Quick Test)

**Step 1: Using Azure CLI**
```bash
# Build your app first, then:
cd /path/to/your/app
zip -r deploy.zip .

# Deploy
az webapp deploy \
  --resource-group webapp-rg \
  --name my-awesome-app \
  --src-path deploy.zip \
  --type zip
```

### Option C: Deploy from VS Code
```
1. Install "Azure App Service" extension in VS Code
2. Sign in to Azure (Ctrl+Shift+P → "Azure: Sign In")
3. Right-click your project folder
4. Select "Deploy to Web App..."
5. Select your App Service
6. Click "Deploy"
```

### Option D: FTP/FTPS Upload
```
1. App Service → Deployment Center → "FTPS credentials" tab
2. Note the:
   - FTPS Endpoint: ftps://waws-prod-xxx.ftp.azurewebsites.windows.net
   - Username: my-awesome-app\$my-awesome-app
   - Password: (shown here)
3. Use FileZilla or WinSCP:
   - Connect with FTPS credentials
   - Upload to /site/wwwroot/
```

---

## 3. Configure Custom Domain

### Prerequisites
```
✅ App Service on Basic tier or higher (Free/Shared don't support custom domains)
✅ You own the domain (e.g., myapp.com)
✅ Access to your domain's DNS settings
```

### Step-by-Step

**Step 1: Navigate to Custom Domains**
```
1. App Service → Left menu → "Custom domains"
2. Click "+ Add custom domain"
```

**Step 2: Add Domain**
```
1. Panel opens:
   ┌──────────────────────────────────────────────────────────┐
   │ Domain provider    │ "All other domain services"          │
   │                    │ (or "App Service Domain" if bought   │
   │                    │ through Azure)                       │
   │ TLS/SSL certificate│ "App Service Managed Certificate"    │
   │                    │ (free! auto-renews)                  │
   │                    │ OR "Add certificate later"           │
   │ Domain name        │ www.myapp.com                        │
   └──────────────────────────────────────────────────────────┘

2. Click "Validate"
3. Azure shows DNS records you need to create:
```

**Step 3: Configure DNS Records**
```
Azure tells you to create these records at your domain registrar:

For www.myapp.com (CNAME):
┌──────────────────────────────────────────────────────────┐
│ Type: CNAME                                              │
│ Name: www                                                │
│ Value: my-awesome-app.azurewebsites.net                  │
└──────────────────────────────────────────────────────────┘

For myapp.com (root/apex domain — A record):
┌──────────────────────────────────────────────────────────┐
│ Type: A                                                  │
│ Name: @ (or leave blank)                                 │
│ Value: <IP shown by Azure>                               │
│                                                          │
│ PLUS a TXT record for verification:                      │
│ Type: TXT                                                │
│ Name: asuid                                              │
│ Value: <verification ID shown by Azure>                  │
└──────────────────────────────────────────────────────────┘

Go to your DNS provider and add these records!
```

**Step 4: Validate and Add**
```
1. After DNS records propagate (can take 5-30 minutes)
2. Back in Azure, click "Validate" again
3. If validation passes (green checkmarks):
   ✅ Domain ownership: Verified
   ✅ CNAME/A record: Configured
4. Click "Add"
5. ✅ Custom domain appears in the list!
6. Browse to https://www.myapp.com — it works!
```

---

## 4. Enable SSL Certificate

### Option A: Free Managed Certificate (Recommended!)

```
If you selected "App Service Managed Certificate" in Step 3,
it's already done! The free cert:
- Auto-issues after domain validation
- Auto-renews every 60 days
- Covers the specific domain name
- ⚠️ Does NOT support wildcard (*.myapp.com)
- ⚠️ Does NOT support root/apex domains with some registrars
```

### Option B: Upload Your Own Certificate

**Step 1: Navigate**
```
1. App Service → Left menu → "Certificates"
2. Click "+ Add certificate"
3. Choose:
   - "App Service Managed Certificate" (free, basic)
   - "Import from Key Vault" (if cert is in Key Vault)
   - "Upload certificate (.pfx)" (your own cert)
```

**Step 2: Upload PFX**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ PFX certificate file     │ Browse → select your .pfx file      │
│ Certificate password     │ Password used when exporting .pfx   │
│ Certificate friendly     │ myapp-2024-cert                      │
│ name                     │                                      │
└─────────────────────────────────────────────────────────────────┘

Click "Validate" → "Add"
```

**Step 3: Bind Certificate to Domain**
```
1. Go to "Custom domains"
2. Find your domain in the list
3. Under "SSL Binding" column, click "Add binding"
4. Select:
   - Custom domain: www.myapp.com
   - Certificate: myapp-2024-cert
   - TLS/SSL type: "SNI SSL" (default, recommended)
5. Click "Add"
6. ✅ HTTPS is now working for your custom domain!
```

**Step 4: Enforce HTTPS**
```
1. App Service → Left menu → "Configuration"
2. "General settings" tab
3. HTTPS Only: "On" (toggle switch)
4. This redirects all HTTP → HTTPS automatically
5. Click "Save"
```

---

## 5. Configure App Settings

### Application Settings (Environment Variables)

**Step 1: Navigate**
```
1. App Service → Left menu → "Configuration"
2. "Application settings" tab (default view)
```

**Step 2: Add a Setting**
```
1. Click "+ New application setting"
2. Fill in:
   ┌──────────────────────────────────────────────────────────┐
   │ Name:  DATABASE_URL                                      │
   │ Value: Server=myserver.database.windows.net;Database=db  │
   │ Deployment slot setting: ☐ (check if slot-specific)     │
   └──────────────────────────────────────────────────────────┘
3. Click "OK"
4. ⚠️ Click "Save" at the top! (settings are NOT saved until you click Save)
5. App will RESTART when you save

Common settings to add:
- WEBSITE_NODE_DEFAULT_VERSION: 20-lts
- DATABASE_URL: connection string
- API_KEY: your-api-key-here
- ASPNETCORE_ENVIRONMENT: Production
```

### Connection Strings
```
1. Same page → "Connection strings" tab
2. Click "+ New connection string"
3. Fill in:
   - Name: DefaultConnection
   - Value: Server=tcp:myserver.database.windows.net,1433;...
   - Type: SQLAzure (dropdown: SQLAzure, MySQL, PostgreSQL, Custom)
4. Click "OK" → "Save"

In your code, access via:
- .NET: Configuration.GetConnectionString("DefaultConnection")
- Node.js: process.env.SQLAZURECONNSTR_DefaultConnection
- Python: os.environ['SQLAZURECONNSTR_DefaultConnection']
```

### General Settings
```
1. "General settings" tab
2. Configure:
   - Stack settings: Runtime version, startup command
   - Platform settings:
     - Platform: 64-bit or 32-bit
     - Web sockets: On/Off
     - Always On: "On" (keeps app warm — requires Basic+)
     - ARR affinity: "On" (sticky sessions) / "Off"
     - HTTPS Only: "On" (force HTTPS)
     - Minimum TLS version: 1.2 (recommended)
3. Click "Save"
```

---

## 6. Deployment Slots

### What Are Slots?
```
Slots = separate instances of your app with their own URLs
- Production: my-awesome-app.azurewebsites.net
- Staging: my-awesome-app-staging.azurewebsites.net

Deploy to staging → Test → Swap to production (zero downtime!)
Requires: Standard tier or higher
```

### Create a Deployment Slot

**Step 1: Navigate**
```
1. App Service → Left menu → "Deployment slots"
2. Click "+ Add Slot"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Name                     │ staging                              │
│                          │ (URL becomes: app-name-staging.      │
│                          │ azurewebsites.net)                   │
│ Clone settings from      │ "my-awesome-app" (copies settings)   │
│                          │ OR "Do not clone settings"           │
└─────────────────────────────────────────────────────────────────┘

Click "Add"
```

### Swap Slots (Zero-Downtime Deployment)

**Step 1: Deploy to Staging First**
```
1. Change your CI/CD to deploy to the STAGING slot
2. Or deploy manually:
   az webapp deploy --slot staging --resource-group webapp-rg \
     --name my-awesome-app --src-path deploy.zip --type zip
```

**Step 2: Test Staging**
```
1. Browse to: https://my-awesome-app-staging.azurewebsites.net
2. Verify everything works
```

**Step 3: Swap**
```
1. App Service → Deployment slots
2. Click "Swap" at the top
3. Configure:
   - Source: staging
   - Target: production (the main slot)
   - "Preview changes" shows setting differences
4. Click "Swap"
5. ✅ Staging is now Production (and vice versa)!
6. If something is wrong → Swap again to rollback!
```

### Slot-Specific Settings
```
Some settings should NOT swap (stay with the slot):
1. Go to Configuration → App settings
2. Check "Deployment slot setting" box for:
   - Database connection strings (prod DB ≠ staging DB)
   - API keys specific to environment
   - Feature flags
   - Application Insights instrumentation key
```

---

## 7. Configure Autoscale

### Step-by-Step

**Step 1: Navigate**
```
1. App Service → Left menu → "Scale out (App Service plan)"
2. Click "Rules Based" (or "Custom autoscale")
```

**Step 2: Configure Autoscale Rules**
```
1. Click "+ Add a rule"
2. Panel opens:

Scale OUT rule (add instances):
┌─────────────────────────────────────────────────────────────────┐
│ Metric source    │ "Current resource" (App Service plan)       │
│ Metric name      │ "CPU Percentage" (dropdown)                 │
│                  │ Options: CPU%, Memory%, HTTP Queue Length,   │
│                  │ Disk Queue Length, Data In/Out               │
│ Operator         │ "Greater than"                              │
│ Threshold        │ 70 (when CPU > 70%)                         │
│ Duration         │ 10 minutes (sustained for this long)        │
│ Aggregation      │ "Average"                                   │
│                  │                                              │
│ ACTION:          │                                              │
│ Operation        │ "Increase count by"                         │
│ Instance count   │ 1                                           │
│ Cool down        │ 5 minutes (wait before scaling again)       │
└─────────────────────────────────────────────────────────────────┘

Scale IN rule (remove instances):
┌─────────────────────────────────────────────────────────────────┐
│ Metric name      │ "CPU Percentage"                            │
│ Operator         │ "Less than"                                 │
│ Threshold        │ 30 (when CPU < 30%)                         │
│ Duration         │ 10 minutes                                  │
│ ACTION:          │                                              │
│ Operation        │ "Decrease count by"                         │
│ Instance count   │ 1                                           │
│ Cool down        │ 5 minutes                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Set Instance Limits**
```
┌──────────────────────────────────────────────────────────┐
│ Minimum instances: 2 (always at least 2 for HA)         │
│ Maximum instances: 10 (cost protection)                 │
│ Default instances: 2 (starting point)                   │
└──────────────────────────────────────────────────────────┘

Click "Save"
```

---

## 8. VNet Integration

### What Is VNet Integration?
```
Allows your App Service to access resources INSIDE a VNet:
- Private databases
- VMs on private subnets
- On-premises resources (via VPN/ExpressRoute)

WITHOUT VNet integration:
  App Service → Internet → (can't reach 10.0.x.x)

WITH VNet integration:
  App Service → VNet → Private resources (10.0.x.x) ✅
```

### Step-by-Step

**Step 1: Navigate**
```
1. App Service → Left menu → "Networking"
2. Under "Outbound traffic", find "VNet integration"
3. Click "Add VNet"
   (or click "VNet integration" link → "+ Add VNet")
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Select                             │
├─────────────────────────────────────────────────────────────────┤
│ Virtual Network    │ Select your VNet (must be in same region)  │
│ Subnet             │ Select a DEDICATED subnet                  │
│                    │ ⚠️ Must be empty! No VMs or other services │
│                    │ Create one named "app-integration-subnet"  │
│                    │ Size: /26 or /27 (16-64 addresses)         │
│                    │ Must delegate to Microsoft.Web/serverFarms │
└─────────────────────────────────────────────────────────────────┘

Click "OK"
⏱️ Takes 1-2 minutes
✅ VNet integration configured
```

**Step 3: Route All Traffic Through VNet (Optional)**
```
1. App Service → Configuration → Application settings
2. Add new setting:
   - Name: WEBSITE_VNET_ROUTE_ALL
   - Value: 1
3. This routes ALL outbound traffic through VNet
   (including traffic to Azure services and internet)
4. Click "Save"
```

---

## 9. Configure Logging

### Enable Application Logging

**Step 1: Navigate**
```
1. App Service → Left menu → "App Service logs"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Application logging    │                                        │
│ (Filesystem)           │ "On" — logs to local disk              │
│                        │ Level: Error / Warning / Information    │
│                        │ Retention: 1-30 days                   │
│                        │                                        │
│ Application logging    │ "On" — logs to Blob Storage            │
│ (Blob)                 │ Storage account: select one            │
│                        │ Retention: days                        │
│                        │                                        │
│ Web server logging     │ "File System" or "Storage"             │
│                        │ Quota: 35 MB                           │
│                        │ Retention: days                        │
│                        │                                        │
│ Detailed error         │ "On" — HTML error pages                │
│ messages               │                                        │
│                        │                                        │
│ Failed request         │ "On" — detailed trace for failures     │
│ tracing                │                                        │
└─────────────────────────────────────────────────────────────────┘

Click "Save"
```

**Step 3: View Logs**
```
Option 1: Log Stream (real-time)
1. Left menu → "Log stream"
2. Select: "Application logs" or "Web server logs"
3. Logs appear in real-time as requests come in

Option 2: Advanced Tools (Kudu)
1. Left menu → "Advanced Tools" → "Go"
2. Opens Kudu console (https://my-app.scm.azurewebsites.net)
3. Debug Console → CMD or PowerShell
4. Navigate: /LogFiles/ → Application/ → View logs

Option 3: Application Insights
1. Left menu → "Application Insights"
2. Click "View Application Insights data"
3. Rich dashboard: Response times, failures, dependencies
4. Search → Filter by error code, time range, etc.
```

---

## 10. Troubleshooting

### ❌ Mistake 1: App Shows 502 Bad Gateway
```
Problem: Browsing to your app shows 502 error

Diagnosis:
1. App Service → "Diagnose and solve problems"
2. Search: "502" → Click "HTTP 502 errors"
3. Azure provides detailed analysis

Common causes:
- App is crashing on startup (check logs!)
- Health check endpoint failing
- App takes too long to start (>230 seconds)
- Runtime version mismatch

Fix:
1. Check Log Stream for startup errors
2. App Service → Configuration → General settings:
   - Verify runtime stack is correct
   - Check startup command (Linux): e.g., "gunicorn app:app"
3. Increase startup timeout:
   - Add setting: WEBSITES_CONTAINER_START_TIME_LIMIT = 600
4. Scale up temporarily (more CPU/RAM)
```

### ❌ Mistake 2: Deployment Slot Swap Fails
```
Problem: Swap operation fails or app errors after swap

Diagnosis:
1. Activity Log → Find "Swap Web App Slots" → Check error

Common causes:
- Staging has different settings that break in production
- Connection string points to wrong database after swap
- Warmup failed (app didn't respond during swap)

Fix:
1. Mark environment-specific settings as "slot setting":
   Configuration → Check "Deployment slot setting" box
2. Add warmup path:
   Configuration → Health check → Path: /health
3. Test staging thoroughly before swapping
4. If broken after swap: Swap again to rollback immediately!
```

### ❌ Mistake 3: Custom Domain Shows "Not Secure"
```
Problem: Browser shows security warning for custom domain

Diagnosis:
1. Custom domains → Check SSL State column:
   - "Not Secure" = no certificate bound
   - "SNI SSL" = certificate bound ✅

Fix:
1. Custom domains → Find domain → Check "SSL Binding"
2. If "Not Secure":
   - Click "Add binding"
   - Select managed certificate (or upload one)
   - Select "SNI SSL"
   - Click "Add"
3. Ensure HTTPS Only is "On" in General settings
4. Wait 1-2 minutes for cert to provision
```

### ❌ Mistake 4: VNet Integration Not Working
```
Problem: App can't reach private resources (database, VM)

Diagnosis:
1. Networking → VNet integration → Check status
2. Look for "Connected" status

Common causes:
- Subnet is too small (no available IPs)
- Subnet not delegated to Microsoft.Web/serverFarms
- NSG on integration subnet blocks traffic
- App setting WEBSITE_VNET_ROUTE_ALL not set

Fix:
1. Check subnet delegation: VNet → Subnets → Click subnet
   → "Delegate subnet to a service" = "Microsoft.Web/serverFarms"
2. Check NSG allows outbound to your destination
3. Add WEBSITE_VNET_ROUTE_ALL = 1 (for private DNS resolution)
4. Restart the app after VNet integration changes
```

### ❌ Mistake 5: App Slow or High Response Time
```
Problem: App response time is high (>5 seconds)

Diagnosis:
1. App Service → Diagnose and solve problems → "Performance"
2. Application Insights → Performance blade
3. Check: CPU%, Memory%, request queue

Fix:
1. Scale UP: Change pricing tier (more CPU/RAM per instance)
   App Service Plan → Scale up → Choose higher tier
2. Scale OUT: Add more instances
   Scale out → Increase instance count
3. Enable "Always On": Configuration → General → Always On: On
   (Prevents cold starts)
4. Check dependencies: App Insights → Dependencies
   - Slow database queries? Add caching
   - Slow external API? Add retry/timeout
5. Enable local cache:
   Add setting: WEBSITE_LOCAL_CACHE_OPTION = Always
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create Web App | App Services → + Create → Web App |
| Deploy code | Deployment Center → Configure source |
| Custom domain | Custom domains → + Add custom domain |
| SSL certificate | Certificates → + Add certificate |
| App settings | Configuration → Application settings |
| Deployment slots | Deployment slots → + Add Slot |
| Swap slots | Deployment slots → Swap |
| Autoscale | Scale out → Rules Based |
| VNet integration | Networking → VNet integration |
| View logs | Log stream (real-time) |
| Diagnostics | Diagnose and solve problems |
| Restart app | Overview → Restart button |

---

## 📊 Pricing Tiers Comparison

```
┌────────────────────────────────────────────────────────────────┐
│ Tier        │ Cost    │ Features                               │
├────────────────────────────────────────────────────────────────┤
│ Free (F1)   │ $0      │ 1GB, 60min/day compute, no custom     │
│             │         │ domain, no SSL, no slots               │
│ Shared (D1) │ ~$10/mo │ Custom domain, 240min compute/day     │
│ Basic (B1)  │ ~$13/mo │ Custom domain, SSL, manual scale (3)  │
│ Standard(S1)│ ~$70/mo │ Slots (5), autoscale (10), VNet       │
│ Premium(P1) │ ~$138/mo│ Slots (20), more scale, VNet inject   │
│ Isolated    │ ~$350/mo│ Dedicated hardware (ASE), max security│
└────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Related Labs
- [Lab 27: App Service 502](../lab-27-app-service-502/)
- [Lab 28: Function App Timeout](../lab-28-function-app-timeout/)
- [Lab 29: App Service Slot Swap Failed](../lab-29-app-service-slot-swap-failed/)
- [Lab 30: App Service VNet Integration](../lab-30-app-service-vnet-integration/)
- [Lab 31: Function App Scaling Stuck](../lab-31-function-app-scaling-stuck/)
- [Lab 32: App Service Custom Domain SSL](../lab-32-app-service-custom-domain-ssl/)
