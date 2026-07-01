#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 18: Sidecar Injection Failure..."
echo "===================================================="

# Delete the namespace (removes all namespaced resources)
kubectl delete namespace lab-18-sidecar --ignore-not-found=true
echo "✅ Namespace deleted"

echo ""
echo "🧹 Lab 18 cleanup complete!"
