## Solution: Lab 14

### Root Cause
Load Balancer health probe failing: wrong port/path

### Fix (Azure CLI)
```bash
az network lb probe list --lb-name <lb> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network lb probe list --lb-name <lb> -g <rg>
# Should now show the correct/working state
```
