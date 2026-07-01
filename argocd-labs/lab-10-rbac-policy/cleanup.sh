#!/bin/bash
echo "🧹 Cleaning up Lab 10: RBAC Policy"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f appproject.yaml --ignore-not-found
kubectl delete namespace rbac-lab --ignore-not-found
echo "⚠️  Note: argocd-rbac-cm was modified. Restore it manually if needed."
echo "✅ Cleanup complete"
