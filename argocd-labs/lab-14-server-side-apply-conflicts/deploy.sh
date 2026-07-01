#!/bin/bash
set -e

echo "🚀 Deploying Lab 14: Server-Side Apply Conflicts — HPA vs ArgoCD"
echo "=================================================================="

# Create namespace
kubectl create namespace scaling-app --dry-run=client -o yaml | kubectl apply -f -

# Apply Deployment
echo "📦 Deploying web-frontend..."
kubectl apply -f deployment.yaml

# Apply HPA
echo "📈 Applying HPA..."
kubectl apply -f hpa.yaml

# Apply the diff customization to argocd-cm
echo "📝 Applying diff customization to argocd-cm..."
kubectl apply -f argocd-cm-diffing.yaml

# Apply the ArgoCD Application with broken ignoreDifferences
echo "🔗 Creating ArgoCD Application..."
kubectl apply -f application.yaml

# Simulate HPA scaling by patching replicas
echo "🔄 Simulating HPA scale-up (replicas 3 → 5)..."
kubectl scale deployment web-frontend -n scaling-app --replicas=5 2>/dev/null || true

echo ""
echo "✅ Lab 14 deployed!"
echo ""
echo "🔍 The Application shows OutOfSync because ArgoCD and HPA both manage spec.replicas."
echo "   The ignoreDifferences configuration has errors — find and fix them."
echo ""
echo "📋 Commands to start investigating:"
echo "   argocd app get scaling-app"
echo "   argocd app diff scaling-app"
echo "   kubectl get application scaling-app -n argocd -o jsonpath='{.spec.ignoreDifferences}' | jq"
echo "   kubectl get hpa -n scaling-app"
