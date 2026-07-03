## Solution: Lab 33

### Root Cause
Storage Account: SAS expired, firewall blocking VNet

### Fix (Azure CLI)
```bash
az storage account show -n <storage>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az storage account show -n <storage>
# Should now show the correct/working state
```
