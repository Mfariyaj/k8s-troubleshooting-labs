## Solution: Lab 39

### Root Cause
Lifecycle policy not transitioning blobs to cool tier

### Fix (Azure CLI)
```bash
az storage account management-policy show -n <sa> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az storage account management-policy show -n <sa> -g <rg>
# Should now show the correct/working state
```
