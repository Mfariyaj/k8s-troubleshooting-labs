## Solution: Lab 18

### Root Cause
Front Door routing requests to wrong backend origin

### Fix (Azure CLI)
```bash
az afd route list --profile-name <fd> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az afd route list --profile-name <fd> -g <rg>
# Should now show the correct/working state
```
