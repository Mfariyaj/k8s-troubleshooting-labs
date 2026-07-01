#!/bin/bash
set -e

echo "🚀 Deploying Lab 12: ApplicationSet Generator — Duplicates and Missing Apps"
echo "============================================================================="

# Apply cluster secrets
echo "🔑 Creating cluster secrets..."
kubectl apply -f cluster-secrets/secrets.yaml

# Apply the broken ApplicationSet
echo "📝 Applying broken ApplicationSet..."
kubectl apply -f applicationset.yaml

echo ""
echo "✅ Lab 12 deployed!"
echo ""
echo "🔍 Expected: 6 applications (3 services × 2 clusters)"
echo "   Actual: Check how many were generated..."
echo ""
echo "📋 Commands to start investigating:"
echo "   kubectl get applicationsets -n argocd"
echo "   kubectl get applications -n argocd -l app.kubernetes.io/managed-by=applicationset-controller"
echo "   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-applicationset-controller --tail=50"
echo "   kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=cluster --show-labels"
