#!/bin/bash
set -e

echo "🚀 Deploying Lab 13: Notification Controller — Notifications Never Send"
echo "========================================================================="

# Apply notification ConfigMap
echo "📝 Applying notification configuration..."
kubectl apply -f argocd-notifications-cm.yaml

# Apply notification secret
echo "🔑 Applying notification secret..."
kubectl apply -f argocd-notifications-secret.yaml

# Apply the ArgoCD Application with notification annotations
echo "🔗 Creating ArgoCD Application..."
kubectl apply -f application.yaml

# Restart notification controller to pick up changes
echo "🔄 Restarting notification controller..."
kubectl rollout restart deployment argocd-notifications-controller -n argocd 2>/dev/null || true

echo ""
echo "✅ Lab 13 deployed!"
echo ""
echo "🔍 Notifications should fire on sync success and health degradation."
echo "   Nothing is being sent — find out why."
echo ""
echo "📋 Commands to start investigating:"
echo "   kubectl get cm argocd-notifications-cm -n argocd -o yaml"
echo "   kubectl get secret argocd-notifications-secret -n argocd -o jsonpath='{.data}' | jq 'keys'"
echo "   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=50"
