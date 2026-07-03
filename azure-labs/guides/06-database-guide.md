# 🗄️ Azure Database Services - Complete Portal Step-by-Step Guide

> Every field, every tab — for Azure SQL Database, Cosmos DB, and Azure Cache for Redis.

---

## Table of Contents
1. [Create Azure SQL Database](#1-create-azure-sql-database)
2. [Configure SQL Firewall Rules](#2-configure-sql-firewall-rules)
3. [Connect to Azure SQL](#3-connect-to-azure-sql)
4. [Create Cosmos DB Account](#4-create-cosmos-db)
5. [Create Cosmos DB Database & Container](#5-create-cosmos-db-database)
6. [Create Azure Cache for Redis](#6-create-azure-cache-for-redis)
7. [Configure Redis Firewall & Access](#7-configure-redis-access)
8. [Set Up SQL Failover Groups](#8-sql-failover-groups)
9. [Backup & Restore](#9-backup-and-restore)
10. [Troubleshooting & Common Mistakes](#10-troubleshooting)

---

## 1. Create Azure SQL Database

### Step-by-Step

**Step 1: Navigate to SQL Databases**
```
1. Open https://portal.azure.com
2. Search bar → Type "SQL databases"
3. Click "SQL databases" from results
4. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ Select existing or "Create new"      │
│                          │ → Name: "database-rg" → OK           │
│                          │                                      │
│ DATABASE DETAILS:        │                                      │
│ Database name            │ myapp-database                       │
│                          │                                      │
│ SERVER:                  │                                      │
│ Server                   │ Click "Create new"                   │
│                          │ → Server name: myapp-sql-server      │
│                          │   (globally unique .database.         │
│                          │    windows.net)                       │
│                          │ → Location: East US                  │
│                          │ → Authentication method:             │
│                          │   "Use SQL authentication"           │
│                          │   OR "Use Microsoft Entra auth only" │
│                          │   OR "Use both" (recommended)        │
│                          │ → Server admin login: sqladmin       │
│                          │ → Password: P@ssw0rd123!             │
│                          │ → Confirm password                   │
│                          │ → Click "OK"                         │
│                          │                                      │
│ Want to use SQL elastic  │ "No" (or Yes for multi-DB pools)     │
│ pool?                    │                                      │
│                          │                                      │
│ Workload environment     │ "Production" or "Development"        │
│                          │ (affects default compute/storage)    │
│                          │                                      │
│ COMPUTE + STORAGE:       │                                      │
│ Click "Configure         │ Opens compute tier page:             │
│ database"                │                                      │
│                          │ Service tier options:                │
│                          │ ○ General Purpose (balanced)         │
│                          │ ○ Business Critical (high IOPS)     │
│                          │ ○ Hyperscale (scale out)             │
│                          │                                      │
│                          │ Compute tier:                        │
│                          │ ○ Provisioned (always on)            │
│                          │ ○ Serverless (auto-pause!) ← dev    │
│                          │                                      │
│                          │ If Serverless:                       │
│                          │ - Max vCores: 2                      │
│                          │ - Min vCores: 0.5                    │
│                          │ - Auto-pause delay: 60 minutes       │
│                          │ - Data max size: 32 GB               │
│                          │                                      │
│                          │ If Provisioned:                      │
│                          │ - vCores: 2 (Gen5)                   │
│                          │ - Data max size: 32 GB               │
│                          │                                      │
│                          │ DTU model (alternative):             │
│                          │ - Basic: 5 DTU, $5/mo                │
│                          │ - Standard S0: 10 DTU, $15/mo        │
│                          │ - Standard S1: 20 DTU, $30/mo        │
│                          │                                      │
│                          │ Click "Apply"                        │
│                          │                                      │
│ BACKUP STORAGE:          │                                      │
│ Backup storage           │ "Locally-redundant" (cheapest)       │
│ redundancy               │ "Zone-redundant" (HA within region)  │
│                          │ "Geo-redundant" (cross-region DR)    │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Networking"
```

**Step 3: Networking Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Network connectivity         │                                  │
│ Connectivity method          │ ○ No access (lock down)          │
│                              │ ○ Public endpoint (default)      │
│                              │ ● Private endpoint (recommended) │
│                              │                                  │
│ If Public endpoint:          │                                  │
│ Firewall rules:              │                                  │
│ Allow Azure services and     │ "Yes" (so App Service can        │
│ resources to access this     │ connect)                         │
│ server                       │                                  │
│ Add current client IP        │ "Yes" (so YOU can connect now)   │
│ address                      │                                  │
│                              │                                  │
│ If Private endpoint:         │                                  │
│ Click "+ Add private         │                                  │
│ endpoint"                    │ (same flow as networking guide)  │
│                              │                                  │
│ Connection policy            │ "Default" (Redirect inside       │
│                              │ Azure, Proxy from outside)       │
│                              │ "Proxy" (always proxy — slower)  │
│                              │ "Redirect" (always redirect)     │
│                              │                                  │
│ Minimum TLS version          │ TLS 1.2 (required, secure)       │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Security"
```

**Step 4: Security Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Enable Microsoft Defender    │ "Enable" (threat detection)      │
│ for SQL                      │ Free 60-day trial, then ~$15/mo  │
│                              │                                  │
│ Ledger                       │ "Not configured" (default)       │
│                              │ Enable for tamper-evident records │
│                              │                                  │
│ Enable Transparent Data      │ ☑ Service-managed key (default)  │
│ Encryption (TDE)             │ Or customer-managed key via KV   │
│                              │                                  │
│ Server identity              │ System assigned (default)        │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Additional settings"
```

**Step 5: Additional Settings Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Data source                  │ "None" (empty database)          │
│                              │ "Backup" (restore from backup)   │
│                              │ "Sample" (AdventureWorks sample) │
│                              │ Select "Sample" for testing!     │
│                              │                                  │
│ Database collation           │ SQL_Latin1_General_CP1_CI_AS     │
│                              │ (default — leave as-is)          │
│                              │                                  │
│ Maintenance window           │ "System default" (Fri-Sun 9PM)   │
│                              │ Or choose specific schedule      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Tags" → Add tags → "Review + create" → "Create"
⏱️ Takes 2-5 minutes
```

---

## 2. Configure SQL Firewall Rules

### Allow Your IP to Connect

**Step 1: Navigate to Server Firewall**
```
1. Go to your SQL Database → Overview
2. Click "Set server firewall" link at the top
   (or: SQL Server → Left menu → "Networking")
```

**Step 2: Add Firewall Rule**
```
┌─────────────────────────────────────────────────────────────────┐
│ Public network access         │ "Selected networks"             │
│                               │                                 │
│ Firewall rules:               │                                 │
│ + Add a firewall rule:        │                                 │
│   Rule name: MyOffice         │                                 │
│   Start IP: 203.0.113.50     │                                 │
│   End IP:   203.0.113.50     │ (same IP = single address)      │
│                               │                                 │
│ + Add your client IPv4        │ ← Click this button!            │
│   address (auto-detects)      │ Adds your current IP            │
│                               │                                 │
│ Allow Azure services          │ ☑ Check this box                │
│ and resources                 │ (lets App Service connect)      │
└─────────────────────────────────────────────────────────────────┘

Click "Save"
```

### Allow a VNet Subnet (Better Than IP Rules!)
```
1. Same Networking page → "Virtual networks" tab
2. Click "+ Add a virtual network rule"
3. Configure:
   - Name: allow-app-subnet
   - Subscription: yours
   - Virtual network: my-app-vnet
   - Subnet: app-subnet
4. Click "OK"
⚠️ This auto-enables service endpoint on the subnet
```

---

## 3. Connect to Azure SQL

### Get Connection String

**Step 1: Find Connection String**
```
1. SQL Database → Left menu → "Connection strings"
2. You'll see tabs for different drivers:
   - ADO.NET
   - JDBC
   - ODBC
   - PHP
   - Go

ADO.NET example:
Server=tcp:myapp-sql-server.database.windows.net,1433;
Initial Catalog=myapp-database;
Persist Security Info=False;
User ID=sqladmin;
Password={your_password};
MultipleActiveResultSets=False;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

### Connect Using Query Editor (Built-in Portal Tool)

**Step 1: Open Query Editor**
```
1. SQL Database → Left menu → "Query editor (preview)"
2. Login:
   - Authentication type: "SQL server authentication"
   - Login: sqladmin
   - Password: P@ssw0rd123!
3. Click "OK"
4. ⚠️ If error "Client IP not allowed":
   - Click the link in error message to add your IP
   - Then try logging in again
```

**Step 2: Run Queries**
```
-- The editor opens with a query window
-- Try:
SELECT TOP 10 * FROM SalesLT.Customer;

-- Create a table:
CREATE TABLE Users (
    ID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Email NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Insert data:
INSERT INTO Users (Name, Email) VALUES ('John', 'john@example.com');

Click "Run" button (or F5)
Results appear below the query window
```

---

## 4. Create Cosmos DB

### Step-by-Step

**Step 1: Navigate to Cosmos DB**
```
1. Search bar → "Azure Cosmos DB"
2. Click "Azure Cosmos DB"
3. Click "+ Create"
4. Choose API:
   ┌──────────────────────────────────────────────────────────┐
   │ API OPTIONS (choose one — CANNOT change later!):        │
   │                                                          │
   │ ● Azure Cosmos DB for NoSQL  ← Most common/recommended │
   │   (JSON documents, SQL-like queries)                    │
   │                                                          │
   │ ○ Azure Cosmos DB for MongoDB                           │
   │   (MongoDB wire protocol compatible)                    │
   │                                                          │
   │ ○ Azure Cosmos DB for PostgreSQL                        │
   │   (Distributed PostgreSQL — Citus)                      │
   │                                                          │
   │ ○ Azure Cosmos DB for Apache Cassandra                  │
   │   (Cassandra wire protocol)                             │
   │                                                          │
   │ ○ Azure Cosmos DB for Table                             │
   │   (Key-value, Azure Table Storage compatible)           │
   │                                                          │
   │ ○ Azure Cosmos DB for Apache Gremlin                    │
   │   (Graph database)                                      │
   └──────────────────────────────────────────────────────────┘
5. Click "Create" on your chosen API
```

**Step 2: Basics Tab (NoSQL API)**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ database-rg                          │
│ Account name             │ myapp-cosmos-db                      │
│                          │ (globally unique, lowercase only)    │
│ Location                 │ East US                              │
│ Capacity mode            │ "Provisioned throughput" (control    │
│                          │ RU/s yourself)                       │
│                          │ OR "Serverless" (pay per request     │
│                          │ — great for dev/test/low traffic)    │
│ Apply Free Tier Discount │ "Apply" (first account only!)        │
│                          │ Gives 1000 RU/s + 25GB free          │
│ Limit total account      │ ☐ Don't limit (or ☑ set max RU/s)   │
│ throughput               │                                      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Global Distribution"
```

**Step 3: Global Distribution Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Geo-redundancy           │ "Disable" (single region, cheaper)   │
│                          │ "Enable" (multi-region, HA)          │
│ Multi-region writes      │ "Disable" (single write region)      │
│                          │ "Enable" (write anywhere — costly!)  │
│ Availability Zones       │ "Disable" or "Enable" (zone HA)     │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Networking"
```

**Step 4: Networking Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                        │ What to Select                   │
├─────────────────────────────────────────────────────────────────┤
│ Connectivity method          │ "All networks" (easy access)     │
│                              │ "Public endpoint (selected       │
│                              │ networks)" (IP/VNet restricted)  │
│                              │ "Private endpoint"               │
│                              │                                  │
│ If Public + selected:        │                                  │
│ Allow access from Azure      │ ☑ Check                          │
│ portal                       │                                  │
│ Allow access from my IP      │ ☑ Check                          │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Backup Policy"
```

**Step 5: Backup Policy Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Backup policy                │ "Periodic" (default)             │
│                              │ "Continuous (7 days)"            │
│                              │ "Continuous (30 days)"           │
│                              │                                  │
│ If Periodic:                 │                                  │
│ Backup interval              │ 240 minutes (4 hours)            │
│ Backup retention             │ 8 hours (min) to 720 hours       │
│ Backup storage redundancy    │ Geo-redundant (default)          │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Encryption" → defaults → "Review + create" → "Create"
⏱️ Takes 5-10 minutes
```

---

## 5. Create Cosmos DB Database & Container

### After Account is Created

**Step 1: Navigate to Data Explorer**
```
1. Cosmos DB account → Left menu → "Data Explorer"
2. This is where you create databases and containers
```

**Step 2: Create a Database**
```
1. Click "New Database" (or "New Container" creates both)
2. Fill in:
   ┌──────────────────────────────────────────────────────────┐
   │ Database id          │ myapp-db                           │
   │ Provision throughput │ ☑ Yes (shared across containers)   │
   │ Database throughput  │ "Autoscale"                        │
   │   Autoscale max RU/s │ 4000 (scales between 400-4000)    │
   │   OR Manual          │ 400 RU/s (fixed)                  │
   └──────────────────────────────────────────────────────────┘
3. Click "OK"
```

**Step 3: Create a Container (Collection)**
```
1. Click "New Container"
2. Fill in:
   ┌──────────────────────────────────────────────────────────┐
   │ Database id          │ "Use existing" → myapp-db          │
   │ Container id         │ users                              │
   │ Partition key        │ /userId                            │
   │                      │ ⚠️ CRITICAL! Choose wisely:        │
   │                      │ - High cardinality (many values)   │
   │                      │ - Used in most queries             │
   │                      │ - Evenly distributes data          │
   │                      │ - CANNOT change after creation!    │
   │                      │                                    │
   │ Indexing             │ "Automatic" (default, index all)   │
   │ Unique keys          │ Optional: /email (enforces unique) │
   └──────────────────────────────────────────────────────────┘
3. Click "OK"
```

**Step 4: Insert and Query Documents**
```
1. In Data Explorer → Expand myapp-db → users → Items
2. Click "New Item"
3. Enter JSON:
   {
     "id": "1",
     "userId": "user-001",
     "name": "John Doe",
     "email": "john@example.com",
     "age": 30
   }
4. Click "Save"

5. Click "New SQL Query"
6. Type: SELECT * FROM c WHERE c.age > 25
7. Click "Execute Query"
8. Results shown below with RU charge displayed
```

---

## 6. Create Azure Cache for Redis

### Step-by-Step

**Step 1: Navigate**
```
1. Search bar → "Azure Cache for Redis"
2. Click "Azure Cache for Redis"
3. Click "+ Create"
```

**Step 2: Basics Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Enter                        │
├─────────────────────────────────────────────────────────────────┤
│ Subscription             │ Select your subscription             │
│ Resource group           │ database-rg                          │
│ DNS name                 │ myapp-redis                          │
│                          │ (becomes myapp-redis.redis.cache.    │
│                          │ windows.net)                         │
│ Location                 │ East US                              │
│ Cache SKU                │ "Standard" (with replication)        │
│                          │ Options:                             │
│                          │ Basic C0: 250MB, no SLA (~$16/mo)    │
│                          │ Basic C1: 1GB (~$36/mo)              │
│                          │ Standard C0: 250MB, HA (~$41/mo)     │
│                          │ Standard C1: 1GB, HA (~$73/mo)       │
│                          │ Premium P1: 6GB, VNet, cluster       │
│                          │ (~$172/mo)                           │
│ Cache size               │ C1 (1GB) for standard workloads     │
│ Availability zones       │ Select if using Premium tier         │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Networking"
```

**Step 3: Networking Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Connectivity method      │ "Public endpoint" (default)          │
│                          │ "Private endpoint" (recommended      │
│                          │ for production)                      │
│                          │ "VNet" (Premium tier only —           │
│                          │ injects into your VNet)              │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Advanced"
```

**Step 4: Advanced Tab**
```
┌─────────────────────────────────────────────────────────────────┐
│ Field                    │ What to Select                       │
├─────────────────────────────────────────────────────────────────┤
│ Redis version            │ 6 (latest stable)                    │
│ Non-TLS port (6379)      │ "Disabled" (security — use TLS!)    │
│                          │ ⚠️ Only enable for legacy apps       │
│ Microsoft Entra          │ "Enabled" (token-based auth)         │
│ Authentication           │ OR "Disabled" (use access keys)      │
│ Access Keys              │ "Enabled" (default)                  │
│ Authentication           │                                      │
└─────────────────────────────────────────────────────────────────┘

Click "Next: Tags" → "Review + create" → "Create"
⏱️ Takes 15-20 minutes to provision!
```

---

## 7. Configure Redis Access

### Get Connection Information

**Step 1: Get Connection String**
```
1. Redis Cache → Left menu → "Access keys"
2. You'll see:
   - Host name: myapp-redis.redis.cache.windows.net
   - Port: 6380 (SSL) or 6379 (non-SSL)
   - Primary key: xxxxxxxxxxxxxxxxxxxxxxxxxxx=
   - Primary connection string:
     myapp-redis.redis.cache.windows.net:6380,password=xxx,ssl=True,abortConnect=False
3. 🚨 Copy the PRIMARY connection string (use in your app)
```

**Step 2: Configure Firewall (Public Endpoint)**
```
1. Redis Cache → Left menu → "Private endpoint connections"
   OR → "Firewall" (for IP rules)
2. For Firewall:
   - Add your IP: Start IP / End IP
   - Or leave empty to allow all Azure services
3. Click "Save"
```

### Test Connection (Redis Console)
```
1. Redis Cache → Left menu → "Console" (preview)
2. A Redis CLI opens in the browser:
   > PING
   PONG

   > SET greeting "Hello World"
   OK

   > GET greeting
   "Hello World"

   > INFO server
   (shows Redis version, uptime, etc.)
```

---

## 8. SQL Failover Groups

### What Is It?
```
Failover Group = Automatic geo-replication + failover for Azure SQL
- Primary server: East US (read-write)
- Secondary server: West US (read-only replica)
- Single connection string works for both!
- Automatic failover if primary goes down
```

### Step-by-Step

**Step 1: Create Secondary Server First**
```
1. Search "SQL servers" → "+ Create"
2. Create a server in a DIFFERENT region:
   - Name: myapp-sql-server-secondary
   - Region: West US (different from primary!)
   - Same admin credentials as primary
3. Click "Review + create" → "Create"
```

**Step 2: Create Failover Group**
```
1. Go to your PRIMARY SQL Server
2. Left menu → "Failover groups"
3. Click "+ Add group"
4. Fill in:
   ┌──────────────────────────────────────────────────────────┐
   │ Failover group name  │ myapp-failover-group              │
   │ Server               │ myapp-sql-server-secondary         │
   │                      │ (select from dropdown)             │
   │                      │                                    │
   │ Read/Write failover  │ "Automatic" (Azure handles it)    │
   │ policy               │ OR "Manual" (you trigger it)       │
   │ Grace period (hours)  │ 1 (wait 1hr before auto-failover) │
   │                      │                                    │
   │ Read-only failover    │ "Enabled" (failover read traffic  │
   │ policy               │ too) or "Disabled"                 │
   │                      │                                    │
   │ Databases            │ ☑ Select databases to include:     │
   │                      │ ☑ myapp-database                   │
   └──────────────────────────────────────────────────────────┘
5. Click "Create"
⏱️ Initial sync takes 5-30 minutes depending on DB size
```

**Step 3: Use Failover Group Connection String**
```
Instead of connecting to the server directly:
  ❌ myapp-sql-server.database.windows.net

Use the failover group listener:
  ✅ myapp-failover-group.database.windows.net (read-write)
  ✅ myapp-failover-group.secondary.database.windows.net (read-only)

This auto-points to whichever server is currently primary!
```

**Step 4: Test Manual Failover**
```
1. SQL Server → Failover groups → Click your group
2. Click "Failover" at the top
3. Confirm: "Yes"
4. ⏱️ Takes 1-5 minutes
5. Roles swap:
   - East US becomes secondary (read-only)
   - West US becomes primary (read-write)
6. Your app using the listener URL → automatically redirected!
```

---

## 9. Backup and Restore

### Azure SQL Automatic Backups
```
Azure SQL automatically backs up:
- Full backup: Weekly
- Differential backup: Every 12-24 hours
- Transaction log: Every 5-10 minutes

Retention:
- Default: 7 days (point-in-time restore)
- Configurable: Up to 35 days (short-term)
- Long-term: Up to 10 years (LTR policy)
```

### Restore to a Point in Time

**Step 1:**
```
1. SQL Database → Left menu → "Overview"
2. Click "Restore" button at the top
3. Configure:
   ┌──────────────────────────────────────────────────────────┐
   │ Database name        │ myapp-database-restored            │
   │ Restore point        │ Select date/time:                  │
   │                      │ e.g., "2024-01-15 14:30:00 UTC"   │
   │ (Earliest available) │ Shows oldest available point       │
   │ Server               │ Same server (or different)         │
   │ Compute + storage    │ Same as source (or modify)         │
   └──────────────────────────────────────────────────────────┘
4. Click "Review + create" → "Create"
5. New database appears with data from that point in time
```

### Configure Long-Term Retention (LTR)
```
1. SQL Server → Left menu → "Backups"
2. Click on your database → "Configure retention"
3. Set:
   - Weekly backup retention: 4 weeks
   - Monthly backup retention: 12 months
   - Yearly backup retention: 5 years
   - Week of year for yearly: Week 1
4. Click "Apply"
```

---

## 10. Troubleshooting

### ❌ Mistake 1: SQL Connection Refused (Firewall)
```
Problem: "Cannot connect to server" or "Client IP not allowed"

Diagnosis:
1. SQL Server → Networking → Check firewall rules
2. Is your IP listed? Is "Allow Azure services" checked?

Fix:
1. SQL Server → Networking
2. Click "+ Add your client IPv4 address"
3. Check "Allow Azure services and resources" ☑
4. Click "Save"
5. If using Private Endpoint: Check DNS resolution
   (must resolve to private IP, not public)
```

### ❌ Mistake 2: Cosmos DB Request Throttled (429)
```
Problem: App gets HTTP 429 "Request rate is large"

Diagnosis:
1. Cosmos DB → Metrics → Look at "Total Requests" with 429 status
2. Check "Normalized RU Consumption" metric — is it near 100%?

Fix Options:
1. Increase RU/s:
   - Data Explorer → Database → Scale → Increase RU/s
   - Or switch to Autoscale
2. Optimize queries:
   - Data Explorer → Run query → Check "Query Stats"
   - High RU charge? Add index or change partition key
3. Use SDK retry logic (built into official SDKs)
4. If burst: Switch to Autoscale (handles spikes better)
```

### ❌ Mistake 3: Redis Connection Timeout
```
Problem: "Timeout connecting to Redis" or "Connection forcibly closed"

Diagnosis:
1. Redis → Left menu → "Metrics"
2. Check: "Connected Clients" (is it at max?)
3. Check: "Server Load" (is it 100%?)
4. Check: "Used Memory" (is it near max?)

Fix:
1. If too many connections:
   - Use connection pooling in your app
   - Reduce idle timeout
   - Scale up Redis tier (higher connection limit)
2. If server overloaded:
   - Scale up (bigger cache size)
   - Enable Redis Cluster (Premium tier — shards data)
3. If timeout from VNet:
   - Check NSG allows port 6380 outbound
   - Check if Redis is in VNet or needs Private Endpoint
4. Non-TLS port disabled but app using 6379:
   - Change app to use port 6380 with SSL=true
```

### ❌ Mistake 4: SQL Failover Group Sync Failed
```
Problem: Secondary database shows "Not Synchronized"

Diagnosis:
1. SQL Server → Failover groups → Check status
2. Look for "Seeding" or "Error" state

Fix:
1. If still seeding: Wait (large DBs take time)
2. If error:
   - Check secondary server firewall (must allow Azure services)
   - Check secondary server has enough DTU/vCore capacity
   - Delete failover group and recreate
3. Monitor: SQL Server → Failover groups → Click group
   - "Replication lag" should be < 5 seconds
```

### ❌ Mistake 5: Cosmos DB Partition Key Wrong
```
Problem: Hot partition — one partition gets all traffic

Diagnosis:
1. Cosmos DB → Metrics → "Normalized RU Consumption by PartitionKeyRangeId"
2. If one partition is much higher → bad partition key!

Understanding:
- Partition key /country → Few values → Uneven distribution
- Partition key /userId → Many values → Even distribution ✅

Fix:
- CANNOT change partition key after creation!
- Must create NEW container with better partition key
- Migrate data from old container to new one
- Use Data Migration tool or custom script
```

---

## 📋 Quick Reference Card

| Task | Portal Path |
|------|-------------|
| Create SQL DB | SQL databases → + Create |
| SQL Firewall | SQL Server → Networking |
| Query Editor | SQL Database → Query editor |
| Connection String | SQL Database → Connection strings |
| Create Cosmos DB | Azure Cosmos DB → + Create |
| Data Explorer | Cosmos DB → Data Explorer |
| Create Redis | Azure Cache for Redis → + Create |
| Redis Keys | Redis → Access keys |
| Redis Console | Redis → Console |
| Failover Group | SQL Server → Failover groups → + Add |
| Restore DB | SQL Database → Restore |
| Backup Policy | SQL Server → Backups |

---

## 📊 Cost Comparison

```
┌────────────────────────────────────────────────────────────────────┐
│ Service          │ Cheapest Dev    │ Production Start │ Notes      │
├────────────────────────────────────────────────────────────────────┤
│ Azure SQL        │ Basic: $5/mo    │ S1: $30/mo       │ Serverless │
│                  │ Serverless: ~$5 │ GP 2vCore: $200  │ auto-pause!│
│ Cosmos DB        │ Serverless: ~$0 │ 400 RU/s: $24/mo │ Free tier  │
│                  │ (pay per req)   │ Autoscale: varies│ available! │
│ Redis            │ Basic C0: $16   │ Standard C1: $73 │ Premium for│
│                  │ (no SLA)        │ Premium P1: $172 │ VNet/HA    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Related Labs
- [Lab 34: Cosmos DB Request Throttled](../lab-34-cosmos-db-request-throttled/)
- [Lab 35: SQL Database Connection Failed](../lab-35-sql-database-connection-failed/)
- [Lab 36: SQL Failover Group Broken](../lab-36-sql-failover-group-broken/)
- [Lab 37: Redis Cache Connection Timeout](../lab-37-redis-cache-connection-timeout/)
- [Lab 38: Storage Replication Lag](../lab-38-storage-replication-lag/)
- [Lab 40: Data Factory Pipeline Failed](../lab-40-data-factory-pipeline-failed/)
