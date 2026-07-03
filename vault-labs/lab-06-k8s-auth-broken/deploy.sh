#!/bin/bash
echo "🚀 Deploying: Kubernetes auth method configured with wrong service account"
docker rm -f vault-lab 2>/dev/null
docker run -d --name vault-lab --cap-add=IPC_LOCK -p 8200:8200 -e 'VAULT_DEV_ROOT_TOKEN_ID=root' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' hashicorp/vault:latest
sleep 3
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root
echo ""
echo "✅ Vault running at http://localhost:8200"
echo "   Token: root"
echo ""
echo "🔍 Scenario: Kubernetes auth method configured with wrong service account"
echo "📋 Your task: Diagnose and fix the issue"
