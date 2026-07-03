## Solution: Lab 34

### Root Cause
Cosmos DB 429: RU/s exceeded, hot partition

### Fix (Azure CLI)
```bash
az cosmosdb show -n <cosmos> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az cosmosdb show -n <cosmos> -g <rg>
# Should now show the correct/working state
```
