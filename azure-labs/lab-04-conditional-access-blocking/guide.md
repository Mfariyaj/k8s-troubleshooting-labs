# 📖 Detailed Guide: Lab 04

## Category: Identity

## Understanding the Problem
CA policy blocking legitimate user login

---

## 🖥️ Azure Portal Steps (GUI)

### Step 1: Navigate to the Resource
1. Open **https://portal.azure.com**
2. Search for the relevant service in the search bar
3. Find the resource mentioned in the error

### Step 2: Check Configuration
1. Look at the resource's settings
2. Check **Activity Log** for error details
3. Check **Diagnose and solve problems** blade

### Step 3: Fix the Issue
1. Edit the misconfigured setting
2. Save changes
3. Wait for propagation

### Step 4: Verify
1. Test the operation that was failing
2. Check Activity Log for success

---

## 💻 Azure CLI Steps

```bash
# Check current state:
az ad conditional-access policy list

# Apply fix:
# (specific commands depend on the issue)

# Verify:
az ad conditional-access policy list
```

---

## 💻 Azure PowerShell Alternative

```powershell
# Login:
Connect-AzAccount

# Check resources:
Get-AzResource -ResourceGroupName <rg>

# Activity Log:
Get-AzActivityLog -StartTime (Get-Date).AddHours(-1)
```

---

## 📖 Reference
- Azure Docs: https://learn.microsoft.com/en-us/azure/
- Troubleshooting: https://learn.microsoft.com/en-us/troubleshoot/azure/
