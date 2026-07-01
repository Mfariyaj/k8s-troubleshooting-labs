#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 14: Server-Side Apply Conflicts"
echo "===================================================="

# Delete ArgoCD Application
kubectl delete application scaling-app -n argocd --ignore-not-found=true

# Delete HPA and Deployment
kubectl delete -f hpa.yaml --ignore-not-found=true 2>/dev/null || true
kubectl delete -f deployment.yaml --ignore-not-found=true 2>/dev/null || true

# Remove diff customization from argocd-cm
kubectl get cm argocd-cm -n argocd -o json | \
  jq 'del(.data["resource.customizations.ignoreDifferences.apps_Deployment"]) | del(.data["resource.compareoptions"])' | \
  kubectl apply -f - 2>/dev/null || true

# Delete namespace
kubectl delete namespace scaling-app --ignore-not-found=true

echo ""
echo "✅ Lab 14 cleaned up!"
