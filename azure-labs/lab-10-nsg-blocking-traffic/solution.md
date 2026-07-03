## Solution: Lab 10

### Root Cause
NSG inbound rule blocking port 443, app unreachable

### Fix (Azure CLI)
```bash
az network nsg rule list --nsg-name <nsg> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network nsg rule list --nsg-name <nsg> -g <rg>
# Should now show the correct/working state
```
