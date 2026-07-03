## Solution: Lab 30

### Root Cause
VNet integration not reaching private SQL/Storage

### Fix (Azure CLI)
```bash
az webapp vnet-integration list -n <app> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az webapp vnet-integration list -n <app> -g <rg>
# Should now show the correct/working state
```
