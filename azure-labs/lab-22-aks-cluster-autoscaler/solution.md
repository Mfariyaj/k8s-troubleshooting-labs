## Solution: Lab 22

### Root Cause
Cluster autoscaler not scaling: VMSS quota hit

### Fix (Azure CLI)
```bash
az aks nodepool show --cluster-name <aks> -n <pool> -g <rg>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az aks nodepool show --cluster-name <aks> -n <pool> -g <rg>
# Should now show the correct/working state
```
