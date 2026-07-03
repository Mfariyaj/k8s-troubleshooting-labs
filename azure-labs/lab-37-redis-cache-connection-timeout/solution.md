## Solution: Lab 37

### Root Cause
Redis: SSL required but app connecting non-SSL port 6379

### Fix (Azure CLI)
```bash
az redis show -n <redis> -g <rg> --query sslPort
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az redis show -n <redis> -g <rg> --query sslPort
# Should now show the correct/working state
```
