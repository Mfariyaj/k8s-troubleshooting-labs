#!/bin/bash
echo "🧹 Cleaning up Lab 06: Resource Exclusion"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f deployment.yaml --ignore-not-found
kubectl delete -f configmap.yaml --ignore-not-found
kubectl delete namespace resource-exclusion-lab --ignore-not-found
echo "⚠️  Note: argocd-cm was modified. Restore it manually if needed."
echo "✅ Cleanup complete"
