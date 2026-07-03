# 🔐 HashiCorp Vault Troubleshooting Labs

## 10 Real-World Broken Vault Scenarios

---

## 📚 What is Vault?

HashiCorp Vault is a **secrets management and data protection** tool. Think of it as a secure safe that:
- Stores passwords, API keys, certificates
- Controls who can access what (policies)
- Auto-generates short-lived credentials (dynamic secrets)
- Encrypts data without you managing keys (transit encryption)

### Why Every Company Uses It:
- ❌ **Without Vault:** Passwords in .env files, hardcoded API keys, shared credentials
- ✅ **With Vault:** Central secret store, audit trail, auto-rotation, least-privilege access

---

## 🏗️ Architecture

```
                    ┌─────────────────────────────┐
                    │        Vault Server          │
                    │                             │
┌──────────┐       │  ┌─────────────────────┐    │
│ Your App │──────>│  │   Auth Methods       │    │
│           │  1.  │  │   - Token            │    │
│           │ Auth │  │   - AppRole          │    │
│           │      │  │   - Kubernetes       │    │
│           │      │  │   - LDAP/OIDC        │    │
└──────────┘       │  └─────────────────────┘    │
      │            │            │                 │
      │            │     2. Token issued          │
      │            │            │                 │
      │            │  ┌─────────────────────┐    │
      │            │  │   Policies (ACL)     │    │
      │◀───────────│  │   "path secret/*    │    │
      │  3. Read   │  │    { capabilities =  │    │
      │  Secret    │  │      [read] }"       │    │
      │            │  └─────────────────────┘    │
      │            │            │                 │
      │            │  ┌─────────────────────┐    │
      │            │  │   Secret Engines     │    │
      │            │  │   - KV (key-value)   │    │
      │            │  │   - Database         │    │
      │            │  │   - PKI (certs)      │    │
      │            │  │   - Transit (encrypt)│    │
      │            │  │   - AWS/SSH          │    │
      │            │  └─────────────────────┘    │
      │            │                             │
      │            │  ┌─────────────────────┐    │
      │            │  │   Storage Backend    │    │
      │            │  │   (Consul/Raft/S3)   │    │
      │            │  └─────────────────────┘    │
      │            └─────────────────────────────┘
      │
      ▼
  Secret returned!
```

---

## 🔑 Key Concepts

### 1. Seal / Unseal
Vault starts **sealed** (locked). It needs unseal keys (Shamir's Secret Sharing) to unlock:
```bash
vault operator init    # Generate root token + 5 unseal keys
vault operator unseal  # Need 3 of 5 keys to unlock
```

### 2. Auth Methods (How you prove WHO you are)
| Method | Use Case | How It Works |
|--------|----------|-------------|
| Token | Default, simplest | Direct token authentication |
| AppRole | Applications/CI | role_id + secret_id = token |
| Kubernetes | Pods in K8s | ServiceAccount JWT → token |
| LDAP/OIDC | Human users | Corporate credentials → token |

### 3. Secret Engines (WHERE secrets are stored/generated)
| Engine | What It Does | Example |
|--------|-------------|---------|
| KV | Store static key-value secrets | API keys, passwords |
| Database | Generate dynamic DB credentials | Temp MySQL user (TTL: 1h) |
| PKI | Issue TLS certificates | Auto-rotate certs |
| Transit | Encrypt/decrypt data | Encrypt before storing in DB |
| AWS | Generate temp AWS credentials | Short-lived IAM keys |

### 4. Policies (WHO can access WHAT)
```hcl
# Allow read on secrets under "myapp/"
path "secret/data/myapp/*" {
  capabilities = ["read", "list"]
}

# Deny everything else (implicit)
```

### 5. Tokens (The access key to everything)
- Every request needs a token
- Tokens have TTL (expire after time)
- Tokens inherit policies
- Can be renewed (if renewable=true)

---

## 🚀 How To Use These Labs

### Prerequisites:
- Docker installed

### Quick Start:
```bash
cd lab-01-vault-sealed
./deploy.sh    # Starts Vault in Docker

# Set environment
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

# Try commands
vault status
vault secrets list
vault kv put secret/myapp password=s3cret
vault kv get secret/myapp
```

---

## 📋 Labs

| # | Lab | Difficulty | What You'll Learn |
|---|-----|-----------|-------------------|
| 01 | Vault Sealed | ⭐ Easy | Seal/unseal mechanism, init process |
| 02 | Auth Method Broken | ⭐⭐ Medium | AppRole auth, role_id/secret_id |
| 03 | Policy Denied | ⭐⭐ Medium | Policy paths, capabilities (CRUD) |
| 04 | Secret Engine Not Enabled | ⭐ Easy | Mounting engines, path routing |
| 05 | Token Expired | ⭐⭐ Medium | Token TTL, renewal, max_ttl |
| 06 | K8s Auth Broken | ⭐⭐⭐ Hard | ServiceAccount JWT, K8s auth config |
| 07 | Dynamic Secrets Failed | ⭐⭐⭐ Hard | Database engine, roles, connection |
| 08 | Transit Encryption | ⭐⭐ Medium | Encrypt/decrypt API, key management |
| 09 | PKI Cert Expired | ⭐⭐⭐ Hard | Certificate authority, chain of trust |
| 10 | Audit Log Full | ⭐⭐⭐ Hard | Audit devices, blocking behavior |

---

## 🛠️ Essential Commands

```bash
# Status & Health
vault status
vault operator seal
vault operator unseal <key>

# Auth
vault login <token>
vault auth enable approle
vault write auth/approle/role/myapp policies="myapp-policy"

# Secrets
vault secrets enable -path=secret kv-v2
vault kv put secret/myapp user=admin pass=s3cret
vault kv get secret/myapp
vault kv get -field=pass secret/myapp

# Policies
vault policy write myapp-policy myapp-policy.hcl
vault policy read myapp-policy
vault token create -policy=myapp-policy

# Dynamic Secrets (Database)
vault secrets enable database
vault write database/config/mydb plugin_name=mysql-database-plugin ...
vault read database/creds/my-role   # Generates temp credentials!

# Transit (Encryption)
vault secrets enable transit
vault write -f transit/keys/my-key
vault write transit/encrypt/my-key plaintext=$(echo "secret" | base64)
vault write transit/decrypt/my-key ciphertext="vault:v1:..."
```

---

## 📖 Reference
- Docs: https://developer.hashicorp.com/vault/docs
- Tutorial: https://developer.hashicorp.com/vault/tutorials
- API: https://developer.hashicorp.com/vault/api-docs
