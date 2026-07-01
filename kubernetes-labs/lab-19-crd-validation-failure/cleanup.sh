#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 19: CRD Validation Failure..."
echo "================================================="

# Delete the CRD (this also deletes all custom resources)
kubectl delete crd databaseclusters.platform.example.com --ignore-not-found=true
echo "✅ CRD deleted"

# Delete the namespace
kubectl delete namespace lab-19-crd --ignore-not-found=true
echo "✅ Namespace deleted"

echo ""
echo "🧹 Lab 19 cleanup complete!"
