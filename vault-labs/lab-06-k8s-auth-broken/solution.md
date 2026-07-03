## Solution: lab-06-k8s-auth-broken

### Root Cause
Kubernetes auth method configured with wrong service account

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
