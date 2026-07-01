#!/bin/bash
set -e

echo "============================================"
echo "Lab 13: Cleanup"
echo "============================================"
echo ""
echo "Removing ARC runner deployment (if applied)..."
echo ""

if command -v kubectl &> /dev/null; then
  kubectl delete -f runner-deployment.yaml --ignore-not-found 2>/dev/null || true
  echo "Runner deployment removed (if it existed)."
else
  echo "kubectl not found — skipping cluster cleanup."
  echo "If you deployed to a cluster, manually run:"
  echo "  kubectl delete -f runner-deployment.yaml"
fi

echo ""
echo "Lab 13 cleanup complete."
