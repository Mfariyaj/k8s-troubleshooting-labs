## Solution: Lab 06

### Root Cause
Custom role missing Microsoft.Compute/virtualMachines/start/action

### Fix (Azure CLI)
```bash
az role definition list --custom-role-only
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az role definition list --custom-role-only
# Should now show the correct/working state
```
