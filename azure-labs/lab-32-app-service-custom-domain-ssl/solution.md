## Solution: Lab 32

### Root Cause
Custom domain SSL binding failed: cert thumbprint wrong

### Fix (Azure CLI)
```bash
az webapp config ssl list -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az webapp config ssl list -g <rg>
# Should now show the correct/working state
```
