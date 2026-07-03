## Solution: Vault Sealed

### Root Cause
Vault was restarted and is in sealed state. When sealed, Vault cannot decrypt any data or serve any API requests (returns 503).

### Step-by-Step Fix

```bash
# 1. Check current status
export VAULT_ADDR=http://localhost:8200
vault status   # Shows Sealed = true

# 2. If vault was never initialized (fresh install):
vault operator init -key-shares=1 -key-threshold=1
# Save the Unseal Key and Root Token!

# 3. Unseal vault (provide keys until threshold met):
vault operator unseal <UNSEAL_KEY>

# 4. Login with root token:
vault login <ROOT_TOKEN>

# 5. Verify:
vault status   # Should show Sealed = false
vault kv get secret/myapp   # Should work now
```

### For Dev/Lab (auto-unseal):
```bash
# Start vault in dev mode (auto-unseals, root token = "root"):
vault server -dev -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200
```

### Prevention
- Use auto-unseal (AWS KMS, Azure Key Vault, GCP Cloud KMS)
- Set up Vault HA with multiple nodes
- Automate unseal in startup scripts (with proper security)
