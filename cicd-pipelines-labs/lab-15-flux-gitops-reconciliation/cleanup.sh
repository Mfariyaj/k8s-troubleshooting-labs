#!/bin/bash
set -e

echo "============================================"
echo "Lab 15: Cleanup"
echo "============================================"
echo ""

if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found — nothing to clean up."
  exit 0
fi

echo "Deleting Flux resources..."
kubectl delete -f flux-system/kustomization.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f flux-system/helmrelease.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f flux-system/gitrepository.yaml --ignore-not-found 2>/dev/null || true

echo ""
echo "Lab 15 cleanup complete."
