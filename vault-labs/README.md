# 🔐 HashiCorp Vault Troubleshooting Labs

## 10 Real-World Broken Vault Scenarios

---

## 🚀 How To Use These Labs

### Prerequisites:
- Docker installed (Vault runs in Docker)
- `vault` CLI (optional): `sudo apt install vault` or download from https://www.vaultproject.io/downloads

### Steps:
1. `cd lab-01-vault-sealed && ./deploy.sh`
2. Vault starts in Docker at http://localhost:8200
3. Observe the error
4. Fix using `vault` CLI or API
5. `./cleanup.sh` when done

---

## 📚 What is Vault?

HashiCorp Vault is a **secrets management tool** that:
- Stores secrets (API keys, passwords, certificates) securely
- Provides dynamic secrets (generate DB credentials on-demand)
- Encrypts data in transit (Transit engine)
- Manages access with policies and authentication

### Key Concepts:
- **Seal/Unseal**: Vault starts sealed (locked). Must be unsealed with keys to operate.
- **Auth Methods**: How clients prove identity (Token, AppRole, Kubernetes, LDAP)
- **Secret Engines**: Where secrets are stored (KV, Database, PKI, Transit)
- **Policies**: Rules defining who can access what paths
- **Tokens**: Every operation needs a token with attached policies

---

## 📋 Labs

| # | Lab | Difficulty | Scenario |
|---|-----|-----------|----------|
| 01 | Vault Sealed | ⭐ Easy | Vault is sealed, can't read secrets |
| 02 | Auth Method Broken | ⭐⭐ Medium | AppRole auth fails (wrong credentials) |
| 03 | Policy Denied | ⭐⭐ Medium | Policy too restrictive, access denied |
| 04 | Secret Engine Not Enabled | ⭐ Easy | KV path not found |
| 05 | Token Expired | ⭐⭐ Medium | Token TTL expired, renewal failed |
| 06 | K8s Auth Broken | ⭐⭐⭐ Hard | Kubernetes auth wrong service account |
| 07 | Dynamic Secrets Failed | ⭐⭐⭐ Hard | Database dynamic secrets not working |
| 08 | Transit Encryption Error | ⭐⭐ Medium | Encrypt/decrypt wrong key or context |
| 09 | PKI Cert Expired | ⭐⭐⭐ Hard | Certificate chain broken |
| 10 | Audit Log Full | ⭐⭐⭐ Hard | Audit device blocking all operations |

---

## 🛠️ Useful Commands

```bash
export VAULT_ADDR=http://localhost:8200
vault status
vault login <token>
vault secrets list
vault auth list
vault policy list
vault kv get secret/myapp
vault token lookup
```
