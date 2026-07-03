## Solution: Lab 11

### Root Cause
VNet peering status Connected but traffic not flowing

### Fix (Azure CLI)
```bash
az network vnet peering list --vnet-name <vnet> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network vnet peering list --vnet-name <vnet> -g <rg>
# Should now show the correct/working state
```
