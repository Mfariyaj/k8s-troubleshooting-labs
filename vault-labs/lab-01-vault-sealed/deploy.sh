#!/bin/bash
echo "🚀 Deploying Lab 01: Vault Sealed"
echo ""

# Remove existing
docker rm -f vault-lab 2>/dev/null

# Start Vault in server mode (NOT dev mode — so it stays sealed!)
docker run -d \
  --name vault-lab \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e 'VAULT_LOCAL_CONFIG={"backend":{"file":{"path":"/vault/data"}},"listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}},"ui":true}' \
  hashicorp/vault:latest server

sleep 3

echo "✅ Vault running at http://localhost:8200"
echo ""
echo "📋 Try these commands:"
echo "   export VAULT_ADDR=http://localhost:8200"
echo "   vault status"
echo ""
echo "❌ Expected: Vault is SEALED (can't read/write secrets)"
echo "🔍 Your task: Initialize and unseal Vault so it can serve requests"
echo ""
echo "💡 Steps:"
echo "   1. vault operator init -key-shares=1 -key-threshold=1"
echo "   2. vault operator unseal <UNSEAL_KEY from step 1>"
echo "   3. vault login <ROOT_TOKEN from step 1>"
echo "   4. vault status (should show Sealed = false)"
