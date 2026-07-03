## Solution: lab-09-pki-cert-expired

### Root Cause
PKI certificate expired, chain validation fails

### Fix
Check vault status and configuration, then apply the correct settings.

### Verification
```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault secrets list
```
