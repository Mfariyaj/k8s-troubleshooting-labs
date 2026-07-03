# 📦 Azure Storage - Complete Portal Step-by-Step Guide

> Every field, every tab — for Storage Accounts, Blob Storage, File Shares, SAS Tokens, and Lifecycle Management.

---

## Table of Contents
1. [Create a Storage Account](#1-create-a-storage-account)
2. [Create Blob Containers & Upload Files](#2-create-blob-containers)
3. [Generate SAS Tokens (Shared Access Signatures)](#3-generate-sas-tokens)
4. [Configure Access Tiers (Hot/Cool/Archive)](#4-configure-access-tiers)
5. [Set Up Lifecycle Management Policies](#5-lifecycle-management)
6. [Create Azure File Shares](#6-create-file-shares)
7. [Configure Storage Firewall & Private Access](#7-configure-storage-firewall)
8. [Enable Static Website Hosting](#8-static-website-hosting)
9. [Configure Replication & Redundancy](#9-configure-replication)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Create a Storage Account

### Step-by-Step

**Step 1: Navigate to Storage Accounts**
```
1. Open https://portal.azure.com
2. Search bar → Type "Storage accounts"
3. Click "Storage accounts" from results
4. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ Select existing or "Create new"      │
│                          │ → Name: "storage-rg" → OK            │
│                          │                                      │
│ INSTANCE DETAILS:        │                                      │
│ Storage account name     │ myappstorage2024                     │
│                          │ (globally unique, 3-24 chars,        │
│                          │ lowercase letters and numbers only!) │
│ Region                   │ East US                              │
│ Performance              │ "Standard" (HDD-backed, cheaper)     │
│                          │ "Premium" (SSD-backed, low latency)  │
│ Redundancy               │ "Locally-redundant storage (LRS)"    │
│                          │ Options:                             │
│                          │ LRS: 3 copies in ONE datacenter     │
│                          │ ZRS: 3 copies across 3 zones        │
│                          │ GRS: 6 copies (3 local + 3 remote)  │
│                          │ GZRS: ZRS + remote copy (best HA)   │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Advanced"
```

**Step 3: Advanced Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ SECURITY:                    │                                  │
│ Require secure transfer      │ ☑ Enabled (HTTPS only)           │
│ (HTTPS)                      │ ⚠️ Always keep enabled!          │
│ Allow enabling anonymous     │ ☐ Disabled (recommended)         │
│ access on containers         │ Enable only for public content   │
│ Enable storage account key   │ ☑ Enabled (default)              │
│ access                       │ Disable to force AAD-only auth   │
│ Default to Microsoft Entra   │ ☐ Disabled (or ☑ if AAD-only)    │
│ authorization in portal      │                                  │
│ Minimum TLS version          │ TLS 1.2 (keep this!)             │
│                              │                                  │
│ DATA LAKE STORAGE GEN2:      │                                  │
│ Enable hierarchical          │ ☐ Disabled (unless using ADLS)   │
│ namespace                    │ ☑ Enable for Data Lake workloads │
│                              │                                  │
│ BLOB STORAGE:                │                                  │
│ Enable SFTP                  │ ☐ Disabled (unless needed)       │
│ Enable network file system   │ ☐ Disabled                       │
│ v3 (NFS)                     │                                  │
│                              │                                  │
│ ACCESS TIER:                 │                                  │
│ Default blob access tier     │ "Hot" (frequently accessed data) │
│                              │ "Cool" (infrequently accessed —  │
│                              │ cheaper storage, costlier access) │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Networking"
```

**Step 4: Networking Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ NETWORK ACCESS:              │                                  │
│ Network access               │ "Enable public access from all   │
│                              │ networks" (default, easy)        │
│                              │ "Enable public access from       │
│                              │ selected virtual networks and    │
│                              │ IP addresses" (restricted)       │
│                              │ "Disable public access and use   │
│                              │ private access" (most secure)    │
│                              │                                  │
│ If "Selected networks":      │                                  │
│ Virtual networks             │ + Add virtual network            │
│                              │ → Select VNet + Subnet           │
│ Firewall                     │ + Add your client IP             │
│ Allow Azure services on the  │ ☑ Check this!                    │
│ trusted services list        │                                  │
│                              │                                  │
│ NETWORK ROUTING:             │                                  │
│ Routing preference           │ "Microsoft network routing"      │
│                              │ (default, lower latency)         │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Data protection"
```

**Step 5: Data Protection Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ RECOVERY:                    │                                  │
│ Enable point-in-time restore │ ☐ Optional (for blob versioning) │
│ Enable soft delete for blobs │ ☑ Enabled (7 days default)       │
│                              │ Can recover deleted blobs!       │
│ Enable soft delete for       │ ☑ Enabled (7 days)               │
│ containers                   │                                  │
│ Enable soft delete for file  │ ☑ Enabled (7 days)               │
│ shares                       │                                  │
│                              │                                  │
│ TRACKING:                    │                                  │
│ Enable versioning for blobs  │ ☐ Optional (keeps all versions)  │
│ Enable blob change feed      │ ☐ Optional (tracks changes)      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Encryption" → defaults are fine
Click "Next: Tags" → Add tags
Click "Review + create" → "Create"
⏱️ Takes 30 seconds - 1 minute
```

---

## 2. Create Blob Containers

### What Are Containers?
```
Storage Account → Container (like a folder) → Blobs (files)

Example structure:
myappstorage2024/
├── images/          (container)
│   ├── logo.png     (blob)
│   └── banner.jpg   (blob)
├── backups/         (container)
│   └── db-2024.bak  (blob)
└── logs/            (container)
    └── app.log      (blob)
```

### Create a Container

**Step 1: Navigate**
```
1. Storage Account → Left menu → "Containers" (under Data storage)
2. Click "+ Container"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Name               │ images (lowercase, hyphens ok)             │
│ Anonymous access   │ "Private" ← Default, most secure!         │
│ level              │ "Blob" = anyone with URL can read blobs    │
│                    │ "Container" = anyone can list + read all   │
│                    │ ⚠️ Only use Blob/Container for truly       │
│                    │ public content (website images, downloads) │
└─────────────────────────────────────────────────────────────────┘

Click "Create"
```

### Upload Files to a Container

**Step 1: Open Container**
```
1. Click on the container name (e.g., "images")
2. Click "Upload" button at the top
```

**Step 2: Upload**
```
1. Panel opens on the right:
   - "Browse for files" OR drag and drop files
   - Select one or multiple files
2. Expand "Advanced" section:
   ┌──────────────────────────────────────────────────────────┐
   │ Upload to folder     │ photos/2024 (virtual directory)   │
   │ Blob type            │ "Block blob" (default, up to      │
   │                      │ 190.7 TB per blob)                │
   │                      │ "Page blob" (for VHD disks)       │
   │                      │ "Append blob" (for logs)          │
   │ Block size           │ Auto (or specify for large files) │
   │ Access tier          │ "Hot" / "Cool" / "Archive"        │
   │ Encryption scope     │ Default                           │
   └──────────────────────────────────────────────────────────┘
3. Click "Upload"
4. ✅ File appears in the container list
```

### Get Blob URL
```
1. Click on the blob name (e.g., "logo.png")
2. In the blob properties, you'll see:
   URL: https://myappstorage2024.blob.core.windows.net/images/logo.png
3. Copy this URL
4. ⚠️ This URL only works if container is "Blob" or "Container" access
   If "Private" → Need SAS token or auth to access
```

---

## 3. Generate SAS Tokens

### What Is a SAS Token?
```
SAS = Shared Access Signature
A URL parameter that grants LIMITED, TIME-BOUND access to storage.

Without SAS: https://mystore.blob.core.windows.net/images/logo.png
  → 404 (if private container)

With SAS: https://mystore.blob.core.windows.net/images/logo.png?sv=2022&st=...&se=...&sp=r&sig=xxx
  → 200 (access granted until expiry!)
```

### Generate SAS for a Specific Blob

**Step 1: Navigate**
```
1. Storage Account → Containers → Open container → Click on blob
2. Click "Generate SAS" tab
```

**Step 2: Configure SAS**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Signing method           │ "Account key" (or "User delegation  │
│                          │ key" — more secure, uses Azure AD)  │
│ Signing key              │ Key 1 (default)                      │
│ Permissions              │ ☑ Read (check what you need):        │
│                          │ ☐ Add                                │
│                          │ ☐ Create                             │
│                          │ ☐ Write                              │
│                          │ ☐ Delete                             │
│                          │ ☐ List (for containers)              │
│ Start date/time          │ Now (or future time)                 │
│ Expiry date/time         │ +1 hour / +1 day / custom           │
│                          │ ⚠️ Keep as SHORT as possible!        │
│ Allowed IP addresses     │ Optional: restrict to specific IP   │
│ Allowed protocols        │ "HTTPS only" (recommended)          │
└─────────────────────────────────────────────────────────────────┘

Click "Generate SAS token and URL"
```

**Step 3: Copy Results**
```
You'll see:
- Blob SAS token: ?sv=2022-11-02&st=2024-01-15...&sig=xxxxx
- Blob SAS URL: https://myappstorage2024.blob.core.windows.net/images/logo.png?sv=2022...

🚨 Copy the FULL SAS URL — it only shows ONCE!
Share this URL with whoever needs temporary access.
```

### Generate SAS for Entire Storage Account

**Step 1: Account-Level SAS**
```
1. Storage Account → Left menu → "Shared access signature"
2. Configure:
   ┌──────────────────────────────────────────────────────────┐
   │ Allowed services     │ ☑ Blob ☑ File ☑ Queue ☑ Table    │
   │ Allowed resource     │ ☑ Service ☑ Container ☑ Object   │
   │ types                │                                    │
   │ Allowed permissions  │ ☑ Read ☑ Write ☑ List etc.       │
   │ Start/Expiry         │ Set time window                   │
   │ Allowed protocols    │ HTTPS only                        │
   │ Signing key          │ Key 1                             │
   └──────────────────────────────────────────────────────────┘
3. Click "Generate SAS and connection string"
4. Copy what you need:
   - Connection string (for SDKs)
   - SAS token (for URLs)
   - Blob service SAS URL
```

---

## 4. Configure Access Tiers

### Understanding Tiers
```
┌────────────────────────────────────────────────────────────────────┐
│ Tier      │ Storage Cost │ Access Cost │ Use Case                  │
├────────────────────────────────────────────────────────────────────┤
│ Hot       │ $0.018/GB    │ Low         │ Frequently accessed data  │
│ Cool      │ $0.01/GB     │ Medium      │ Infrequent (30+ days)     │
│ Cold      │ $0.0036/GB   │ Higher      │ Rarely accessed (90+ days)│
│ Archive   │ $0.00099/GB  │ Highest     │ Long-term backup (180+)   │
│           │              │ + rehydrate │ Takes HOURS to access!    │
│           │              │ time        │                           │
└────────────────────────────────────────────────────────────────────┘
```

### Change Tier for a Single Blob
```
1. Navigate to the blob
2. Click on the blob name
3. Click "Change tier" button at the top
4. Select: Hot / Cool / Cold / Archive
5. Click "Save"

⚠️ Moving TO Archive: Blob becomes unreadable until rehydrated!
   Rehydration: Can take up to 15 hours (Standard) or 1 hour (High priority)
```

### Change Tier for Multiple Blobs
```
1. In the container, check multiple blobs (checkboxes)
2. Click "Change tier" at the top menu
3. Select tier → "Save"
4. All selected blobs change tier
```

---

## 5. Lifecycle Management

### What Is It?
```
Automatically move or delete blobs based on age:
- After 30 days: Move from Hot → Cool (save 44% on storage)
- After 90 days: Move from Cool → Archive (save 90%+)
- After 365 days: Delete blob (cleanup)
```

### Create a Lifecycle Policy

**Step 1: Navigate**
```
1. Storage Account → Left menu → "Lifecycle management"
   (under Data management)
2. Click "+ Add a rule"
```

**Step 2: Configure Rule Details**
```
Tab 1 - Details:
┌─────────────────────────────────────────────────────────────────┐
│ Rule name              │ move-to-cool-after-30-days             │
│ Rule scope             │ "Apply rule to all blobs" OR           │
│                        │ "Limit blobs with filters"             │
│ Blob type              │ ☑ Block blobs                          │
│ Blob subtype           │ ☑ Base blobs                           │
│                        │ ☐ Snapshots                            │
│                        │ ☐ Versions                             │
└─────────────────────────────────────────────────────────────────┘

Click "Next"
```

**Step 3: Configure Actions (Base Blobs Tab)**
```
Tab 2 - Base blobs:
┌─────────────────────────────────────────────────────────────────┐
│ Condition                          │ Action                     │
├─────────────────────────────────────────────────────────────────┤
│ Last modified more than X days ago │                            │
│                                    │                            │
│ ☑ Move to cool storage             │ After 30 days              │
│ ☑ Move to cold storage             │ After 90 days              │
│ ☑ Move to archive storage          │ After 180 days             │
│ ☑ Delete the blob                  │ After 365 days             │
│                                    │                            │
│ OR based on:                       │                            │
│ "Last accessed more than X days"   │ (requires access tracking) │
│ "Created more than X days ago"     │                            │
└─────────────────────────────────────────────────────────────────┘

Click "Next" → Filter tab (optional: filter by container or prefix)
Click "Add"
```

**Step 4: Verify Policy**
```
1. Your rules appear in the Lifecycle management page
2. Rules run once per day automatically (within 24-48 hours)
3. Check "Last execution" column to see when it last ran
```

---

## 6. Create File Shares

### What Are Azure File Shares?
```
Azure Files = Fully managed SMB/NFS file shares in the cloud
- Mount as a network drive on Windows (Z:\), Linux (/mnt/share), macOS
- Used for: Shared config files, application data, legacy app migration
- SMB 3.0 (encrypted in transit)
```

### Create a File Share

**Step 1: Navigate**
```
1. Storage Account → Left menu → "File shares" (under Data storage)
2. Click "+ File share"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field              │ What to Enter                              │
├─────────────────────────────────────────────────────────────────┤
│ Name               │ app-config-share                           │
│ Access tier        │ "Transaction optimized" (default, best    │
│                    │ for mixed workloads)                       │
│                    │ "Hot" (optimized for frequent access)      │
│                    │ "Cool" (cost-effective infrequent access)  │
│ Provisioned        │ (Only for Premium storage accounts)       │
│ capacity           │ Specify size in GiB                       │
└─────────────────────────────────────────────────────────────────┘

Click "Create"
```

**Step 3: Upload Files to Share**
```
1. Click on the file share name
2. Click "Upload" → Select files → "Upload"
3. Or click "+ Add directory" to create folders
```

**Step 4: Connect/Mount the File Share**
```
1. Click "Connect" button at the top
2. Select your OS: Windows / Linux / macOS
3. Azure shows the EXACT mount command:

WINDOWS (PowerShell):
───────────────────
$connectTestResult = Test-NetConnection -ComputerName myappstorage2024.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    cmd.exe /C "cmdkey /add:myappstorage2024.file.core.windows.net /user:Azure\myappstorage2024 /pass:ACCESS_KEY_HERE"
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\myappstorage2024.file.core.windows.net\app-config-share" -Persist
}

LINUX:
──────
sudo mkdir /mnt/app-config-share
sudo mount -t cifs //myappstorage2024.file.core.windows.net/app-config-share /mnt/app-config-share -o vers=3.0,username=myappstorage2024,password=ACCESS_KEY,dir_mode=0777,file_mode=0777,serverino

4. Copy and run the command on your machine
5. ✅ File share appears as a network drive!
```

---

## 7. Configure Storage Firewall

### Restrict Access to Specific Networks

**Step 1: Navigate**
```
1. Storage Account → Left menu → "Networking"
2. You'll see the "Firewalls and virtual networks" tab
```

**Step 2: Configure Firewall**
```
┌─────────────────────────────────────────────────────────────────┐
│ Public network access        │ "Enabled from selected virtual  │
│                              │ networks and IP addresses"       │
│                              │                                  │
│ VIRTUAL NETWORKS:            │                                  │
│ + Add existing virtual       │                                  │
│ network                      │                                  │
│   Subscription: yours        │                                  │
│   Virtual networks: my-vnet  │                                  │
│   Subnets: app-subnet        │                                  │
│   → Click "Add"              │                                  │
│                              │                                  │
│ FIREWALL:                    │                                  │
│ + Add your client IP:        │ 203.0.113.50                     │
│   Address range              │                                  │
│                              │                                  │
│ EXCEPTIONS:                  │                                  │
│ ☑ Allow Azure services on    │ ← IMPORTANT for App Service,    │
│ the trusted services list    │ Functions, Data Factory, etc.    │
│ to access this storage       │                                  │
│ account                      │                                  │
│                              │                                  │
│ RESOURCE INSTANCES:          │                                  │
│ + Add resource instances     │ Specific Azure services that     │
│ that can access this account │ need access (e.g., specific      │
│                              │ App Service by name)             │
└─────────────────────────────────────────────────────────────────┘

Click "Save"
⚠️ After enabling firewall, YOU might lose portal access!
   Always add your own IP first.
```

### Configure Private Endpoint (Most Secure)
```
1. Storage Account → Networking → "Private endpoint connections" tab
2. Click "+ Private endpoint"
3. Same flow as networking guide:
   - Name: storage-private-ep
   - Region: East US
   - Target sub-resource: "blob" (or file, table, queue)
   - VNet + Subnet
   - Private DNS zone: privatelink.blob.core.windows.net
4. Click "Create"
```

---

## 8. Static Website Hosting

### What Is It?
```
Host HTML/CSS/JS directly from Azure Blob Storage!
- No web server needed
- Globally distributed via CDN
- Extremely cheap (pennies per month for small sites)
- Great for: React/Vue/Angular SPAs, documentation, landing pages
```

### Enable Static Website

**Step 1: Navigate**
```
1. Storage Account → Left menu → "Static website" (under Data management)
2. Toggle: "Enabled"
```

**Step 2: Configure**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Static website           │ "Enabled"                            │
│ Index document name      │ index.html                           │
│ Error document path      │ 404.html (or index.html for SPAs)   │
└─────────────────────────────────────────────────────────────────┘

Click "Save"

Azure creates a special container: $web
Your website URL: https://myappstorage2024.z13.web.core.windows.net
```

**Step 3: Upload Website Files**
```
1. Go to Containers → Click "$web" container
2. Upload your HTML/CSS/JS files:
   - index.html
   - style.css
   - app.js
   - assets/ (folder with images)
3. Browse to your website URL → ✅ Website is live!
```

**Step 4: Add Custom Domain + CDN (Optional)**
```
1. Search "CDN profiles" → "+ Create"
2. Or: Storage Account → Left menu → "Azure CDN" (under Security + networking)
3. Configure:
   - CDN profile name: myapp-cdn
   - Pricing tier: "Standard Microsoft" (cheapest)
   - CDN endpoint name: myapp
   - Origin: Select your static website URL
4. After CDN deploys, point your custom domain CNAME → myapp.azureedge.net
5. Enable HTTPS on CDN endpoint
```

---

## 9. Configure Replication

### Understanding Redundancy Options

```
┌─────────────────────────────────────────────────────────────────────┐
│ Type │ Copies │ Where                │ Use Case          │ Cost    │
├─────────────────────────────────────────────────────────────────────┤
│ LRS  │ 3      │ 1 datacenter         │ Dev/test          │ $       │
│ ZRS  │ 3      │ 3 zones (1 region)   │ High availability │ $$      │
│ GRS  │ 6      │ 2 regions (3+3)      │ Disaster recovery │ $$$     │
│ GZRS │ 6      │ 3 zones + 1 region   │ Best HA + DR      │ $$$$    │
│ RA-GRS│ 6     │ Same as GRS          │ Read from both    │ $$$+    │
│ RA-GZRS│ 6    │ Same as GZRS         │ Best everything   │ $$$$$   │
└─────────────────────────────────────────────────────────────────────┘

RA = Read-Access: Can read from secondary region (read-only)
```

### Change Replication Type

**Step 1: Navigate**
```
1. Storage Account → Left menu → "Redundancy"
   (under Data management)
```

**Step 2: Change**
```
1. "Redundancy" dropdown → Select new type
   e.g., Change from "LRS" to "GRS"
2. Click "Save"
3. ⚠️ Some changes take time and may have restrictions:
   - LRS → ZRS: Background data migration (may take days!)
   - Any → GRS/GZRS: Immediate (replication starts)
   - Premium → GRS: NOT supported (Premium = LRS/ZRS only)
```

### Check Replication Status (GRS/GZRS)
```
1. Redundancy page shows:
   - Primary location: East US — Available
   - Secondary location: West US — Available
   - Last Sync Time: 2024-01-15 14:30 UTC
2. "Last Sync Time" shows how current the secondary is
   (Usually within seconds to minutes)
```

---

## 10. Troubleshooting

### ❌ Mistake 1: Access Denied (403 Forbidden)
```
Problem: "This request is not authorized to perform this operation"

Diagnosis:
1. Is the container Private? → Need SAS token or Azure AD auth
2. Is the storage firewall blocking you? 
3. Is the SAS token expired?

Checklist:
1. Storage Account → Networking → Is your IP allowed?
2. Container → Access level → Private means no anonymous access
3. If using SAS → Check expiry time
4. If using Azure AD → Check RBAC:
   - Storage Account → IAM → Does user have
     "Storage Blob Data Reader" or "Contributor"?
   ⚠️ "Contributor" on the resource group is NOT enough for data!
      You need STORAGE-SPECIFIC roles.

Fix:
- Add your IP to firewall
- OR generate new SAS token
- OR assign "Storage Blob Data Contributor" role
```

### ❌ Mistake 2: Lifecycle Policy Not Moving Blobs
```
Problem: Blobs not transitioning to Cool/Archive after expected days

Diagnosis:
1. Lifecycle management → Check rule is enabled
2. Check "Last modified" date of blobs (maybe too recent)
3. Check if filter (prefix/container) matches your blobs

Common causes:
- Rule uses "days since last modified" — blob was recently overwritten
- Filter prefix is wrong (case-sensitive!)
- Lifecycle runs once per day — wait 24-48 hours
- Archive tier: Cannot move blobs < 1 KB

Fix:
1. Verify blob last modified date:
   Container → Blob → Properties → Last modified
2. Check rule filters match container/prefix
3. Wait at least 48 hours after rule creation
4. Check if "enableAutoTierToHotFromCool" is needed
```

### ❌ Mistake 3: Cannot Delete Blob or Container
```
Problem: "This blob cannot be deleted because it has active leases"

Diagnosis:
1. Blob has a LEASE (lock) on it
2. Or: Container has a lease
3. Or: Soft delete is making you think it's still there

Fix:
1. Break the lease:
   - Click on blob → "Break lease" button
   - Or via CLI: az storage blob lease break --blob-name X --container Y
2. If legally held by a backup service:
   - Check if Azure Backup is protecting this storage
   - Stop backup before deleting
3. If soft-deleted:
   - Container → "Show deleted blobs" toggle (top of page)
   - You'll see deleted blobs grayed out
   - These auto-purge after retention period
```

### ❌ Mistake 4: Storage Account Name Issues
```
Problem: "Storage account name already taken" or "invalid name"

Rules for storage account names:
- 3 to 24 characters
- Lowercase letters and numbers ONLY (no hyphens, underscores, capitals!)
- Must be globally unique across ALL of Azure!

Fix:
- Add a random suffix: myappstorage2024abc
- Add region: myappstorageeastus
- Add project code: proj42storage
```

### ❌ Mistake 5: Large File Upload Fails
```
Problem: Upload times out or fails for files > 100MB

Diagnosis:
- Portal upload limit: ~256 MB (can be slow for large files)
- Single PUT limit: 5000 MiB (Block blob)

Fix:
1. For files 100MB-5GB: Use Azure CLI (faster, parallel upload)
   az storage blob upload --account-name mystore \
     --container-name backups --name bigfile.zip \
     --file ./bigfile.zip --type block

2. For files > 5GB: Use AzCopy (parallel block upload)
   azcopy copy './bigfile.tar.gz' \
     'https://mystore.blob.core.windows.net/backups/bigfile.tar.gz?SAS_TOKEN'

3. For many files: Use AzCopy sync
   azcopy sync './local-folder' \
     'https://mystore.blob.core.windows.net/container?SAS_TOKEN'
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create Storage Account | Storage accounts → + Create |
| Create Container | Storage Account → Containers → + Container |
| Upload Blob | Container → Upload |
| Generate SAS | Blob → Generate SAS tab |
| Account SAS | Storage Account → Shared access signature |
| Change Tier | Blob → Change tier |
| Lifecycle Rules | Storage Account → Lifecycle management |
| File Shares | Storage Account → File shares → + File share |
| Mount Share | File share → Connect → Copy script |
| Firewall | Storage Account → Networking |
| Static Website | Storage Account → Static website → Enable |
| Change Redundancy | Storage Account → Redundancy |
| Access Keys | Storage Account → Access keys |
| Soft Delete Recovery | Container → Show deleted blobs toggle |

---

## 📊 Cost Awareness

```
Storage is cheap — but costs add up with scale!

Blob Storage (LRS, Hot tier):
- Storage: $0.018/GB/month
- Read operations: $0.004 per 10,000
- Write operations: $0.05 per 10,000

Example costs:
- 100 GB Hot: ~$1.80/month
- 1 TB Hot: ~$18/month
- 1 TB Cool: ~$10/month
- 1 TB Archive: ~$1/month (but $$ to rehydrate!)

⚠️ Data transfer OUT (to internet): $0.087/GB
   Transfer within Azure (same region): Free!
   Transfer between regions: ~$0.02/GB
```

---

## 🔗 Related Labs
- [Lab 33: Storage Account Access Denied](../lab-33-storage-account-access-denied/)
- [Lab 38: Storage Replication Lag](../lab-38-storage-replication-lag/)
- [Lab 39: Blob Lifecycle Not Working](../lab-39-blob-lifecycle-not-working/)
