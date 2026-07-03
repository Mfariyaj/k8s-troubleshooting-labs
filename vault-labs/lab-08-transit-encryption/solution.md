## Solution: lab-08-transit-encryption

### Root Cause
Transit encrypt/decrypt fails with wrong key name

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
