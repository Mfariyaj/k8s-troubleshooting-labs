## Solution: lab-01-vault-sealed

### Root Cause
Vault is sealed and cannot serve requests

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
