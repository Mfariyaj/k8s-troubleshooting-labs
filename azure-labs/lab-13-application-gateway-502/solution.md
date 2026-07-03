## Solution: Lab 13

### Root Cause
App Gateway 502 Bad Gateway: backend pool unhealthy

### Fix (Azure CLI)
```bash
az network application-gateway show-backend-health
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az network application-gateway show-backend-health
# Should now show the correct/working state
```
