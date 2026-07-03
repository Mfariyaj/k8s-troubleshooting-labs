## Solution: lab-02-auth-method-broken

### Root Cause
AppRole authentication fails with invalid credentials

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
