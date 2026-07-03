## Solution: Lab 12

### Root Cause
Private endpoint created but DNS not resolving to private IP

### Fix (Azure CLI)
```bash
az network private-dns zone list -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network private-dns zone list -g <rg>
# Should now show the correct/working state
```
