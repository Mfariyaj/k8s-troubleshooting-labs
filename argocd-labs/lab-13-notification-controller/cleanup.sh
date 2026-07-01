#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 13: Notification Controller"
echo "================================================"

# Delete the Application
kubectl delete application notification-test-app -n argocd --ignore-not-found=true

# Reset notification ConfigMap to empty
kubectl create configmap argocd-notifications-cm -n argocd --dry-run=client -o yaml | kubectl apply -f -

# Delete notification secret
kubectl delete secret argocd-notifications-secret -n argocd --ignore-not-found=true

# Restart notification controller
kubectl rollout restart deployment argocd-notifications-controller -n argocd 2>/dev/null || true

echo ""
echo "✅ Lab 13 cleaned up!"
