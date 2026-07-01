#!/bin/bash
set -e

echo "🚀 Deploying Lab 15: Multi-Source Application — Helm Values from Separate Repo"
echo "================================================================================"

# Create namespace
kubectl create namespace platform --dry-run=client -o yaml | kubectl apply -f -

# Apply the broken multi-source Application
echo "🔗 Creating multi-source ArgoCD Application..."
kubectl apply -f application.yaml

echo ""
echo "✅ Lab 15 deployed!"
echo ""
echo "🔍 The multi-source Application fails to sync."
echo "   Helm chart source cannot find values from the referenced source."
echo ""
echo "📋 Commands to start investigating:"
echo "   argocd app get multi-source-app"
echo "   kubectl get application multi-source-app -n argocd -o jsonpath='{.status.conditions}' | jq"
echo "   kubectl get application multi-source-app -n argocd -o jsonpath='{.spec.sources}' | jq"
echo "   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep multi-source"
