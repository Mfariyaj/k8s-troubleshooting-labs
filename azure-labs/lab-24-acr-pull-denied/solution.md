## Solution: Lab 24

### Root Cause
AKS can't pull from ACR: kubelet identity missing AcrPull role

### Fix (Azure CLI)
```bash
az aks check-acr -n <aks> -g <rg> --acr <acr>
# Then apply the fix (see guide.md for details)
```

### Fix (Azure Portal)
1. Open https://portal.azure.com
2. Navigate to the broken resource
3. Fix the misconfiguration
4. Save and verify

### Verification
```bash
az aks check-acr -n <aks> -g <rg> --acr <acr>
# Should now show the correct/working state
```
