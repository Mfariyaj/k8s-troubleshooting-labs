#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 15: Multi-Source Application"
echo "================================================="

# Delete the Application
kubectl delete application multi-source-app -n argocd --ignore-not-found=true

# Delete namespace
kubectl delete namespace platform --ignore-not-found=true

echo ""
echo "✅ Lab 15 cleaned up!"
