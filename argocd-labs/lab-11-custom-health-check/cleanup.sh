#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 11: Custom Lua Health Check"
echo "================================================"

# Delete ArgoCD Application
kubectl delete application database-app -n argocd --ignore-not-found=true

# Delete custom resource
kubectl delete -f custom-resource.yaml --ignore-not-found=true 2>/dev/null || true

# Remove the health customization from argocd-cm
kubectl get cm argocd-cm -n argocd -o json | \
  jq 'del(.data["resource.customizations.health.databases.example.com/v1alpha1_DatabaseCluster"])' | \
  kubectl apply -f - 2>/dev/null || true

# Delete namespace
kubectl delete namespace databases --ignore-not-found=true

echo ""
echo "✅ Lab 11 cleaned up!"
