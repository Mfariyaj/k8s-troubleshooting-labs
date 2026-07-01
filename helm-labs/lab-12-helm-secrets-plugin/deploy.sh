#!/bin/bash
set -e

echo "============================================"
echo "Lab 12: Helm Secrets Plugin Decryption"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "Attempting to deploy with helm-secrets..."
echo ""
echo "Running: helm secrets install myapp ./mychart -f secrets.yaml --namespace lab12-secrets --create-namespace"
echo ""

# This will fail in multiple ways
helm secrets install myapp ./mychart \
  -f secrets.yaml \
  --namespace lab12-secrets \
  --create-namespace

echo ""
echo "If you see errors above, your task is to fix the helm-secrets integration!"
echo ""
echo "Expected outcome:"
echo "  - SOPS decrypts secrets.yaml using the age key"
echo "  - Decrypted values are passed to helm install"
echo "  - Application deploys with correct secret values"
