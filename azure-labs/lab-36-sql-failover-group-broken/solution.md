## Solution: Lab 36

### Root Cause
Failover group secondary not syncing

### Fix (Azure CLI)
```bash
az sql failover-group show -n <fg> -g <rg> -s <server>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az sql failover-group show -n <fg> -g <rg> -s <server>
# Should now show the correct/working state
```
