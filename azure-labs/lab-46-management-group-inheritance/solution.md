## Solution: Lab 46

### Root Cause
Policy not inheriting through management group hierarchy

### Fix (Azure CLI)
```bash
az account management-group list
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az account management-group list
# Should now show the correct/working state
```
