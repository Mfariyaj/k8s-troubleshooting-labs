#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 12: ApplicationSet Generator"
echo "================================================="

# Delete ApplicationSet (this also deletes generated Applications)
kubectl delete applicationset platform-services-set -n argocd --ignore-not-found=true

# Delete cluster secrets
kubectl delete -f cluster-secrets/secrets.yaml --ignore-not-found=true

# Clean up any orphaned applications
kubectl delete applications -n argocd -l app.kubernetes.io/managed-by=applicationset-controller --ignore-not-found=true 2>/dev/null || true

echo ""
echo "✅ Lab 12 cleaned up!"
