## Solution: Lab 35

### Root Cause
Azure SQL: firewall rule missing, AAD auth not configured

### Fix (Azure CLI)
```bash
az sql server firewall-rule list -s <server> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az sql server firewall-rule list -s <server> -g <rg>
# Should now show the correct/working state
```
