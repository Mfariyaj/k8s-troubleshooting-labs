#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 17: Pod Disruption Budget..."
echo "================================================"

# Delete the namespace (removes all namespaced resources including PDBs)
kubectl delete namespace lab-17-pdb --ignore-not-found=true
echo "✅ Namespace deleted"

echo ""
echo "🧹 Lab 17 cleanup complete!"
