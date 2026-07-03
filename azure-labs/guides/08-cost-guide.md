# 💰 Azure Cost Management - Complete Portal Step-by-Step Guide

> Every click, every field — for Budgets, Cost Analysis, Advisor Recommendations, and Finding Unused Resources.

---

## Table of Contents
1. [View Cost Analysis (Where Is Money Going?)](#1-cost-analysis)
2. [Create a Budget & Alerts](#2-create-a-budget)
3. [Use Azure Advisor (Free Recommendations)](#3-azure-advisor)
4. [Find & Delete Unused Resources](#4-find-unused-resources)
5. [Right-Size VMs (Reduce Overprovisioned)](#5-right-size-vms)
6. [Reserved Instances (Save 30-72%)](#6-reserved-instances)
7. [Set Up Cost Tags for Tracking](#7-cost-tags)
8. [Export Cost Data & Reports](#8-export-cost-data)
9. [Configure Spending Caps & Limits](#9-spending-caps)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Cost Analysis

### What You'll Accomplish
See exactly where your Azure money is going — by service, resource, region, and time.

### Step-by-Step

**Step 1: Navigate to Cost Management**
```
1. Open https://portal.azure.com
2. Search bar → Type "Cost Management"
3. Click "Cost Management + Billing"
4. Left menu → "Cost analysis" (under Cost Management)
   OR: Directly search "Cost analysis"
```

**Step 2: Understand the Default View**
```
You'll see a chart showing costs over time. Key elements:

TOP BAR:
┌─────────────────────────────────────────────────────────────────┐
│ Scope: [Your Subscription ▼]  (can change to RG or MG)        │
│ View: [Accumulated costs ▼]                                     │
│ Date range: [This month ▼] → Custom range available            │
│ Granularity: [Daily ▼] / Monthly / None                        │
└─────────────────────────────────────────────────────────────────┘

CHART AREA:
- Blue line = Actual cost
- Dotted line = Forecast (predicted end-of-month)
- Stacked areas = Cost by category

BELOW CHART:
- Table showing cost breakdown by resource/service/location
```

**Step 3: Change Views (Very Useful!)**
```
Click the "View" dropdown. Built-in views:

1. "Accumulated costs" (default)
   - Shows running total for the period
   - Good for: Budget tracking

2. "Cost by resource"
   - Shows EACH resource's cost
   - Good for: Finding expensive resources

3. "Cost by service"
   - Groups by service type (VMs, Storage, SQL, etc.)
   - Good for: Understanding spending categories

4. "Daily costs"
   - Shows per-day spending
   - Good for: Spotting spikes

5. Custom views:
   - Click "Group by": Resource, Resource group, Tag, Location,
     Service name, Meter, etc.
   - Mix and match to get exactly what you need
   - Click "Save" to keep custom views
```

**Step 4: Filter and Drill Down**
```
Click "+ Add filter":
- Resource group: show only specific RG
- Tag: show only tagged resources (e.g., team=DevOps)
- Service name: show only VMs or only Storage
- Location: show only East US resources

DRILL DOWN:
1. Click on any bar in the chart
2. It zooms into that day/service/resource
3. Click "Resource" column headers to sort by cost
4. Click any resource name to go directly to it
```

**Step 5: Compare Time Periods**
```
1. Date range → Click "Custom"
2. Set: January 1 - January 31
3. Then click "Compare" toggle → "Previous month"
4. Now shows side-by-side comparison:
   - This month vs last month
   - Shows increase/decrease % per category
```

---

## 2. Create a Budget

### What You'll Accomplish
Set spending limits and get email alerts BEFORE you overspend.

### Step-by-Step

**Step 1: Navigate to Budgets**
```
1. Cost Management → Left menu → "Budgets"
   OR: Search "Budgets" in portal
2. Click "+ Add"
```

**Step 2: Create Budget Details**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Scope                    │ Your subscription (or resource group)│
│ Name                     │ monthly-budget-500                   │
│ Reset period             │ "Monthly" (or Quarterly, Annually)   │
│ Creation date            │ Today (auto-filled)                  │
│ Expiration date          │ 12/31/2025 (or leave default 5 yrs) │
│ Budget amount            │ 500 (in USD — your monthly limit)    │
│                          │                                      │
│ FILTER (optional):       │                                      │
│ + Add filter             │ Resource Group: "production-rg"      │
│                          │ (budget applies only to filtered     │
│                          │ resources)                           │
└─────────────────────────────────────────────────────────────────┘

Click "Next"
```

**Step 3: Configure Alerts**
```
Alert conditions section:
┌─────────────────────────────────────────────────────────────────┐
│ Alert #1:                                                       │
│ Type: "Actual" (notify when REACHED)                            │
│ % of budget: 50                                                 │
│ → Alerts when you hit $250 (50% of $500)                       │
│                                                                 │
│ Alert #2:                                                       │
│ Type: "Actual"                                                  │
│ % of budget: 80                                                 │
│ → Alerts when you hit $400                                     │
│                                                                 │
│ Alert #3:                                                       │
│ Type: "Actual"                                                  │
│ % of budget: 100                                                │
│ → Alerts when you hit $500 (full budget!)                      │
│                                                                 │
│ Alert #4:                                                       │
│ Type: "Forecasted" ← This is KEY!                              │
│ % of budget: 100                                                │
│ → Alerts when Azure PREDICTS you'll exceed budget              │
│   (gives you advance warning!)                                 │
│                                                                 │
│ Alert recipients (email):                                       │
│ admin@company.com, devops@company.com                           │
│                                                                 │
│ Language preference: English                                    │
│                                                                 │
│ ACTION GROUP (optional):                                        │
│ Select action group: (for advanced actions like webhook,        │
│ Logic App, or auto-shutdown)                                    │
└─────────────────────────────────────────────────────────────────┘

Click "Create"
✅ Budget is now active!
```

**Step 4: Verify Budget**
```
1. Budgets page → You'll see your budget listed:
   │ Name │ Amount │ Spent │ % Used │ Forecast │
   │ monthly-budget-500 │ $500 │ $127 │ 25% │ $380 │
2. Green = Under budget, Yellow = Near limit, Red = Over!
```

### Budget Alert Actions (Advanced)
```
If you want AUTOMATIC ACTIONS when budget is exceeded:
1. Create an Action Group first:
   - Search "Action groups" → "+ Create"
   - Add actions:
     - Email/SMS/Push/Voice
     - Azure Function (run code)
     - Logic App (complex workflow)
     - Webhook (notify external system)
     - ITSM connector
2. Then in Budget → Alert → Select this Action Group

Example: Auto-shutdown non-production VMs when budget hits 90%
  → Action Group triggers a Logic App that stops VMs with tag
    "environment: dev"
```

---

## 3. Azure Advisor

### What Is Azure Advisor?
```
FREE AI-powered recommendations for:
💰 Cost: Reduce spending (unused resources, right-sizing)
🔒 Security: Fix security issues
⚡ Performance: Improve speed
🛡️ Reliability: Improve uptime
🌱 Operational Excellence: Best practices
```

### Step-by-Step

**Step 1: Navigate to Advisor**
```
1. Search bar → "Advisor"
2. Click "Advisor"
3. You'll see the Advisor dashboard with scores:
   - Cost: 85/100
   - Security: 70/100
   - Reliability: 90/100
   - Performance: 95/100
   - Operational Excellence: 80/100
```

**Step 2: View Cost Recommendations**
```
1. Click "Cost" tab (or the Cost score card)
2. You'll see recommendations like:

COMMON COST RECOMMENDATIONS:
┌─────────────────────────────────────────────────────────────────┐
│ Recommendation                    │ Potential Savings            │
├─────────────────────────────────────────────────────────────────┤
│ "Right-size or shutdown           │ Save $XX/month per VM       │
│ underutilized VMs"               │                              │
│ "Buy reserved instances"          │ Save 30-72% on compute      │
│ "Delete unused public IP          │ Save $3.65/month each       │
│ addresses"                        │                              │
│ "Delete idle virtual network      │ Save $XX/month              │
│ gateways"                         │                              │
│ "Resize underutilized App         │ Save $XX/month              │
│ Service plans"                    │                              │
│ "Consider Cosmos DB reserved      │ Save 20-65%                 │
│ capacity"                         │                              │
│ "Delete unused disks"             │ Save $X/month each          │
└─────────────────────────────────────────────────────────────────┘
```

**Step 3: Act on a Recommendation**
```
1. Click on a recommendation (e.g., "Right-size underutilized VMs")
2. You'll see details:
   - Affected resources: list of VMs
   - Current size: Standard_D4s_v3
   - Recommended size: Standard_D2s_v3
   - Current cost: $140/month
   - New cost: $70/month
   - Monthly savings: $70

3. For each resource, you can:
   - "Resize" → Takes you to VM resize page
   - "Postpone" → Remind later
   - "Dismiss" → Don't show again (for this resource)

4. Some recommendations have "Quick fix" button → One-click apply!
```

**Step 4: Configure Advisor Alerts**
```
1. Advisor → Left menu → "Alerts"
2. Click "+ New advisor alert"
3. Configure:
   - Subscription/RG scope
   - Category: Cost (or all)
   - Impact: High, Medium, Low
   - Action group: (email notification)
4. Click "Create"
   → Get emailed when NEW cost-saving recommendations appear
```

---

## 4. Find Unused Resources

### What to Look For
```
Common unused resources costing money:
💸 Unattached Managed Disks ($5-150/month each!)
💸 Unused Public IP addresses ($3.65/month each)
💸 Idle VPN Gateways ($140-2500/month!)
💸 Empty App Service Plans ($13-350/month)
💸 Stopped-but-not-deallocated VMs (still charged!)
💸 Unused Load Balancers ($18+/month)
💸 Old Snapshots accumulating ($0.05/GB/month)
```

### Find Unattached Disks

**Step 1:**
```
1. Search bar → "Disks"
2. Click "Disks"
3. Look at the "Owner" column (or "Disk state"):
   - "Attached" = in use by a VM ✅
   - "Unattached" = NOT used, still costing money! 💸
4. Filter: Click "Add filter" → Disk state → "Unattached"
5. Review each unattached disk:
   - Is it an old VM's OS disk? → Safe to delete
   - Is it a data disk from a deleted VM? → Check if data needed
6. Select → Delete (after confirming data isn't needed)
```

### Find Unused Public IPs

**Step 1:**
```
1. Search bar → "Public IP addresses"
2. Look at "Associated to" column:
   - Shows resource name if in use ✅
   - Shows "-" or blank if unused 💸
3. Filter by: Associated to = "Not associated"
4. Delete unused ones:
   - Select → Delete
   - ⚠️ Only Standard SKU costs money ($3.65/mo)
   - Basic SKU is free when attached, charged when not
```

### Find Idle VPN Gateways

**Step 1:**
```
1. Search → "Virtual network gateways"
2. For each gateway:
   - Click on it → Connections
   - If NO connections listed → Possibly unused!
   - If connections exist but "Not Connected" for weeks → Investigate
3. Check metrics:
   - Gateway → Metrics → "Tunnel Bandwidth"
   - If consistently 0 for weeks → Not being used
4. Cost: VpnGw1 = ~$140/month for doing NOTHING!
```

### Find Unused App Service Plans

**Step 1:**
```
1. Search → "App Service plans"
2. For each plan, check "Number of apps":
   - 0 apps = Empty plan! Still being charged!
   - Click plan → "Apps" tab → Confirm no apps
3. Delete empty plans:
   - Select plan → Overview → Delete
```

### Find Stopped-but-Charged VMs

**Step 1:**
```
1. Search → "Virtual machines"
2. Check "Status" column:
   - "Running" = Active, fully charged
   - "Stopped" ⚠️ = Still charged! (stopped from inside VM)
   - "Stopped (deallocated)" ✅ = NOT charged (compute free)
3. If status is "Stopped" (without deallocated):
   - Click VM → Stop → Choose "Deallocate"
   - Or in CLI: az vm deallocate --name myvm --resource-group myrg
4. ⚠️ "Stopped" = Guest OS shutdown but Azure still holds the VM
   "Deallocated" = Azure releases the compute (no charge!)
```

---

## 5. Right-Size VMs

### What Is Right-Sizing?
```
Changing VM size to match ACTUAL usage:
- VM has 8 vCPUs but uses only 2 on average → Downsize to 2 vCPU!
- VM has 32 GB RAM but peaks at 5 GB → Downsize to 8 GB!
- Savings: 50-75% of compute cost!
```

### Step-by-Step

**Step 1: Check VM Utilization**
```
1. Go to your VM → Left menu → "Metrics"
2. Add metric: "Percentage CPU"
   - Time range: Last 30 days
   - Aggregation: Average AND Maximum
3. Add another metric: "Available Memory Bytes"
   (or check via monitoring agent inside VM)
4. Analyze:
   - Average CPU < 20%? → Oversized!
   - Max CPU < 40%? → Definitely oversized!
   - Average memory < 30%? → Too much RAM
```

**Step 2: Check Advisor Recommendation**
```
1. Advisor → Cost → "Right-size or shutdown underutilized VMs"
2. Click the recommendation
3. Azure shows:
   - Current size: Standard_D4s_v3 (4 vCPU, 16 GB)
   - Avg CPU: 8.5%
   - Recommended: Standard_D2s_v3 (2 vCPU, 8 GB)
   - Monthly savings: ~$70
```

**Step 3: Resize the VM**
```
1. Go to VM → Left menu → "Size"
2. ⚠️ VM must be STOPPED (deallocated) to resize
   - Some sizes within the same family can resize while running
   - Cross-family always requires stop
3. Stop the VM: Overview → "Stop" button
4. Wait for "Stopped (deallocated)" status
5. Now go to "Size":
   - Search for recommended size (e.g., "D2s_v3")
   - Click on it (row highlights)
   - Click "Resize" button
6. ⏱️ Takes 2-5 minutes
7. Start the VM: "Start" button
8. ✅ Running on smaller (cheaper) hardware!
```

---

## 6. Reserved Instances

### What Are Reserved Instances?
```
Commit to using a resource for 1 or 3 years → Get 30-72% discount!

Example:
- Standard_D4s_v3 Pay-As-You-Go: $140/month
- 1-Year Reserved: $89/month (36% savings!)
- 3-Year Reserved: $56/month (60% savings!)

Works for: VMs, SQL, Cosmos DB, App Service, Redis, Storage, etc.
```

### Purchase a Reservation

**Step 1: Navigate**
```
1. Search bar → "Reservations"
2. Click "Reservations"
3. Click "+ Purchase now" (or "+ Add")
```

**Step 2: Select Product**
```
Choose what to reserve:
- Virtual machine
- SQL Database
- Cosmos DB
- App Service
- Azure Cache for Redis
- Storage
- Databricks
- many more...

Click "Virtual machine" (for this example)
```

**Step 3: Configure Reservation**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Scope                    │ "Shared" (applies to any matching    │
│                          │ VM in subscription)                  │
│                          │ "Single resource group"              │
│                          │ "Single subscription"                │
│ Subscription             │ Select yours                         │
│ Region                   │ East US (must match VM region!)      │
│ VM size                  │ Standard_D4s_v3                      │
│ Term                     │ "1 year" or "3 years"                │
│ Billing frequency        │ "Monthly" or "Upfront" (all at once)│
│ Quantity                 │ 3 (for 3 VMs of this size)           │
│                          │                                      │
│ DISPLAY:                 │                                      │
│ Monthly cost (reserved)  │ $89/month                            │
│ Monthly cost (PAYG)      │ $140/month                           │
│ Monthly savings          │ $51/month per VM                     │
│ Total savings (1 year)   │ $612 per VM                          │
└─────────────────────────────────────────────────────────────────┘

Click "Review + buy" → "Buy now"
⚠️ This is a commitment! You're charged even if VMs are off.
   (Can exchange or refund within limits)
```

**Step 4: View & Manage Reservations**
```
1. Reservations page → Click your reservation
2. You'll see:
   - Utilization: 87% (are your reserved VMs running?)
   - If < 80%: You're overpaying! Reduce reservation quantity.
3. Actions available:
   - "Exchange" → Swap for different size/region
   - "Refund" → Get partial refund (capped at $50k/year)
   - "Split" → Split into smaller reservations
   - "Merge" → Combine multiple reservations
```

### Check Reservation Recommendations
```
1. Advisor → Cost tab
2. Look for: "Buy reserved instances"
3. Azure analyzes your usage patterns and recommends:
   - Which VMs/services would benefit from reservation
   - Expected savings
   - Payback period
```

---

## 7. Cost Tags

### Why Tags?
```
Tags let you track costs by:
- Team/Department: team=DevOps, team=Frontend
- Project: project=website-redesign
- Environment: env=production, env=staging, env=dev
- Cost center: costcenter=CC-4567
- Owner: owner=john.doe@company.com
```

### Apply Tags to Resources

**Step 1: Tag a Single Resource**
```
1. Go to any resource (VM, Storage, etc.)
2. Left menu → "Tags"
3. Add tags:
   - Name: Environment    Value: Production
   - Name: Team           Value: DevOps
   - Name: CostCenter     Value: CC-Engineering
   - Name: Owner          Value: john.doe
4. Click "Apply"
```

**Step 2: Tag a Resource Group (Inherited by Resources)**
```
1. Go to Resource Group → "Tags"
2. Add tags → "Apply"
⚠️ Tags on RG do NOT automatically appear on resources inside!
   But Cost Management can show by RG-level tags.
```

**Step 3: Bulk Tag with Azure Policy (Enforce Tags)**
```
1. Search → "Policy"
2. Click "Assignments" → "+ Assign policy"
3. Search for built-in policy:
   - "Require a tag and its value on resources"
   - "Inherit a tag from the resource group"
   - "Add a tag to resources"
4. Configure:
   - Scope: Your subscription or RG
   - Tag name: CostCenter
   - Tag value: (leave blank to require ANY value)
5. Click "Create"
   → Now NEW resources MUST have this tag or deployment fails!
```

**Step 4: View Costs by Tag**
```
1. Cost Management → Cost analysis
2. Group by → "Tag" → Select tag name (e.g., "Team")
3. Now you see costs split by team:
   │ Team     │ Cost This Month │
   │ DevOps   │ $450            │
   │ Frontend │ $120            │
   │ Backend  │ $380            │
   │ (untagged)│ $200           │ ← Find and tag these!
```

---

## 8. Export Cost Data

### Schedule Automatic Exports

**Step 1: Navigate**
```
1. Cost Management → Left menu → "Exports"
2. Click "+ Add"
```

**Step 2: Configure Export**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Export name              │ monthly-cost-export                   │
│ Export type              │ "Monthly cost of the current month"  │
│                          │ OR "Daily export of month-to-date"   │
│                          │ OR "Weekly export of cost for the    │
│                          │ last 7 days"                         │
│                          │ OR "Custom time range"               │
│                          │                                      │
│ Storage account          │ Select a storage account             │
│ Container                │ cost-exports (create if needed)      │
│ Directory                │ monthly-reports                      │
│ File format              │ CSV (default)                        │
│ Compression              │ None or Gzip                         │
│                          │                                      │
│ SCHEDULE:                │                                      │
│ Start date               │ Beginning of next month              │
│ Recurrence               │ Depends on export type               │
└─────────────────────────────────────────────────────────────────┘

Click "Create"
```

**Step 3: Download Manually**
```
1. Cost Management → Cost analysis
2. Click "Download" button at the top
3. Options:
   - Download as CSV
   - Download as Excel
4. Good for quick one-time reports or sharing with finance team
```

### Create Custom Reports with Power BI
```
1. Cost Management → Left menu → "Cost Management connector for Power BI"
2. Instructions to connect Power BI Desktop:
   - Install Azure Cost Management connector
   - Sign in with Azure AD
   - Select scope (subscription/billing account)
   - Pre-built dashboards for cost analysis!
```

---

## 9. Spending Caps

### Azure Spending Limit (Free/MSDN Subscriptions)
```
⚠️ Spending limits only apply to:
- Free trial subscriptions ($200 credit)
- MSDN/Visual Studio subscriptions
- NOT Pay-As-You-Go subscriptions!

For Pay-As-You-Go: Use BUDGETS (Section 2) for alerts.
Azure will NOT automatically stop your resources.
```

### How to Check/Manage Spending Limit
```
1. Search → "Subscriptions"
2. Click your subscription
3. Look for "Spending limit" status at the top
4. Options:
   - "Remove spending limit indefinitely"
   - "Remove spending limit for current billing period"
   - "Turn on spending limit next billing period"

⚠️ For production: REMOVE the spending limit!
   Otherwise Azure shuts down ALL your resources when credit runs out.
```

### Auto-Shutdown VMs (Dev/Test Cost Saving)

**Step 1: Enable Auto-Shutdown per VM**
```
1. Go to VM → Left menu → "Auto-shutdown"
   (under Operations)
2. Toggle: "Enabled"
3. Configure:
   - Scheduled shutdown time: 7:00 PM
   - Time zone: (your timezone)
   - Send notification before shutdown: "Yes"
   - Email: your-email@company.com
   - Webhook URL: (optional for Slack/Teams alert)
4. Click "Save"
   → VM auto-stops every day at 7 PM!
   → Saves ~66% (only running 8 hours instead of 24)
```

**Step 2: Auto-Shutdown for All Lab VMs (Policy)**
```
1. Search → "Policy"
2. Assign built-in initiative:
   "Configure virtual machines to have auto-shutdown scheduled"
3. Scope: Dev/Test resource group
4. Time: 19:00 (7 PM)
   → All VMs in scope get auto-shutdown configured
```

---

## 10. Troubleshooting

### ❌ Mistake 1: Unexpected High Bill
```
Problem: Azure bill is much higher than expected

Diagnosis:
1. Cost Analysis → View: "Cost by resource" → Sort by cost descending
2. Look for the TOP 5 most expensive resources
3. Common surprise costs:
   - VPN Gateway running 24/7: $140+/month
   - Forgotten VMs in dev/test RG: $50-200/month each
   - Large managed disks (Premium P30/P40): $120-240/month
   - Bandwidth/data transfer (egress): $0.087/GB!
   - Standard public IPs: $3.65/month EACH
   - Log Analytics data ingestion: $2.76/GB

Fix:
1. Delete unused resources immediately
2. Set up budgets with alerts (should've done earlier!)
3. Enable auto-shutdown for dev VMs
4. Switch to reserved instances for stable workloads
5. Move infrequently-used data to Cool/Archive tier
```

### ❌ Mistake 2: Budget Alert Not Firing
```
Problem: Exceeded budget but didn't get an email

Diagnosis:
1. Check Budget configuration:
   - Is email address correct?
   - Is alert threshold correct?
2. Check Alert type: "Actual" vs "Forecasted"
   - "Actual" = alerts AFTER spending happens
   - "Forecasted" = alerts BEFORE (more useful!)
3. Check spam folder!
4. Budget alerts have up to 24-hour delay

Fix:
1. Budget → Edit → Verify email addresses
2. Add BOTH actual AND forecasted alerts
3. Add Action Group for more reliable delivery (SMS, webhook)
4. Add multiple recipients (not just one person)
```

### ❌ Mistake 3: Can't See Costs for All Resources
```
Problem: Cost analysis shows partial data or "no data"

Diagnosis:
1. Check SCOPE: Are you viewing the right subscription?
2. Check PERMISSIONS: Need "Cost Management Reader" role minimum
3. Check time range: Costs appear with 24-48 hour delay
4. Some resources don't show in cost analysis until billed

Fix:
1. Change scope: Click scope selector → Try billing account level
2. Add role: Subscription IAM → "Cost Management Reader"
3. Check: Are resources in a different subscription?
4. Wait 48 hours for recent resources to appear
5. Enterprise Agreement (EA): Check EA portal instead
```

### ❌ Mistake 4: Reserved Instance Not Applying
```
Problem: Bought reservation but still being charged full price

Diagnosis:
1. Reservations → Click reservation → Check "Utilization"
2. Is it 0%? → Reservation not matching any resource!

Common causes:
- Wrong region (reservation in East US but VM in West US)
- Wrong VM size (reserved D4s_v3 but VM is D4_v3 — note the "s"!)
- VM is stopped/deallocated (reservation only applies to running VMs)
- Wrong scope (single RG but VM is in different RG)

Fix:
1. Check region and size EXACTLY match
2. Change scope to "Shared" (applies to whole subscription)
3. If wrong size: Use "Exchange" to swap for correct size
4. Ensure VMs are running to use the reservation
```

### ❌ Mistake 5: Advisor Recommendations Not Showing
```
Problem: Advisor shows no cost recommendations

Reasons:
1. Resources are new (< 7 days old) — Advisor needs usage data
2. All resources are already optimized
3. Using free tier or very small resources
4. Subscriptions not enrolled in Advisor

Fix:
1. Wait at least 7 days for Advisor to analyze usage
2. Ensure Azure Monitor is collecting metrics (VMs → Insights)
3. Check Advisor → Configuration → Ensure subscription is included
4. Manually check:
   - VMs: Metrics → CPU/Memory (are they low?)
   - Disks: Any showing "Unattached"?
   - Public IPs: Any showing "Not associated"?
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| View costs | Cost Management → Cost analysis |
| Create budget | Cost Management → Budgets → + Add |
| Advisor tips | Advisor → Cost tab |
| Find unused disks | Disks → Filter: Disk state = Unattached |
| Find unused IPs | Public IP addresses → Associated = blank |
| Right-size VM | VM → Size (stop first) |
| Buy reservation | Reservations → + Purchase now |
| Apply tags | Any resource → Tags |
| View by tag | Cost analysis → Group by → Tag |
| Export data | Cost Management → Exports → + Add |
| Auto-shutdown | VM → Auto-shutdown → Enable |
| Spending alerts | Budgets → Configure % alerts |

---

## 📊 Cost Saving Cheat Sheet

```
┌─────────────────────────────────────────────────────────────────┐
│ Action                          │ Savings        │ Effort       │
├─────────────────────────────────────────────────────────────────┤
│ Delete unused resources         │ 100% of their  │ ⭐ Easy      │
│                                 │ cost           │              │
│ Auto-shutdown dev VMs           │ ~66%           │ ⭐ Easy      │
│ Right-size oversized VMs        │ 30-75%         │ ⭐⭐ Medium  │
│ Use Spot VMs (non-critical)     │ 60-90%         │ ⭐⭐ Medium  │
│ Storage lifecycle (Hot→Cool)    │ 40-50%         │ ⭐ Easy      │
│ Reserved Instances (1 year)     │ 30-40%         │ ⭐ Easy      │
│ Reserved Instances (3 year)     │ 55-72%         │ ⭐ Easy      │
│ Switch to Serverless            │ 40-80%         │ ⭐⭐⭐ Hard  │
│ Use Azure Hybrid Benefit        │ Up to 85%      │ ⭐ Easy      │
│ (existing Windows licenses)     │ (Windows VMs)  │              │
│ Review data transfer costs      │ Varies         │ ⭐⭐ Medium  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Related Labs
- [Lab 41: Cost - Unused Resources](../lab-41-cost-unused-resources/)
- [Lab 42: Cost - Right-Sizing VMs](../lab-42-cost-right-sizing-vms/)
- [Lab 43: Cost - Reserved Instances](../lab-43-cost-reserved-instances/)
- [Lab 44: Cost - Advisor Recommendations](../lab-44-cost-advisor-recommendations/)
