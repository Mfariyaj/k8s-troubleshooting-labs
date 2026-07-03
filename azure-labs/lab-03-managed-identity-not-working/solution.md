## Solution: Lab 03

### Root Cause
System-assigned MI not enabled, VM can't access Key Vault

### Fix (Azure CLI)
```bash
az vm identity show -n <vm> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az vm identity show -n <vm> -g <rg>
# Should now show the correct/working state
```
