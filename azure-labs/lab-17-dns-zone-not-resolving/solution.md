## Solution: Lab 17

### Root Cause
Private DNS zone not linked to VNet

### Fix (Azure CLI)
```bash
az network private-dns link vnet list -g <rg> -z <zone>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network private-dns link vnet list -g <rg> -z <zone>
# Should now show the correct/working state
```
