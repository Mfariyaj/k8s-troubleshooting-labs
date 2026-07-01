#!/bin/bash
set -e

echo "🚀 Deploying Lab 11: Custom Lua Health Check — Perpetual Progressing"
echo "======================================================================"

# Create namespace
kubectl create namespace databases --dry-run=client -o yaml | kubectl apply -f -

# Apply the broken health check ConfigMap patch
echo "📝 Applying custom health check configuration to argocd-cm..."
kubectl apply -f argocd-cm-health.yaml

# Apply the custom resource (simulating operator-managed resource)
echo "📦 Applying DatabaseCluster custom resource..."
kubectl apply -f custom-resource.yaml 2>/dev/null || echo "⚠️  CRD not installed — resource simulated for lab purposes"

# Apply the ArgoCD Application
echo "🔗 Creating ArgoCD Application..."
kubectl apply -f application.yaml

# Restart ArgoCD controller to pick up ConfigMap changes
echo "🔄 Restarting ArgoCD application controller..."
kubectl rollout restart deployment argocd-application-controller -n argocd 2>/dev/null || true

echo ""
echo "✅ Lab 11 deployed!"
echo ""
echo "🔍 Investigate why the Application health is stuck at 'Progressing'"
echo "   despite the DatabaseCluster resource being fully ready."
echo ""
echo "📋 Commands to start investigating:"
echo "   argocd app get database-app"
echo "   kubectl get cm argocd-cm -n argocd -o yaml"
echo "   kubectl get databasecluster prod-postgres -n databases -o yaml"
