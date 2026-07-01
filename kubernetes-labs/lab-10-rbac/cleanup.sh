#!/bin/bash
# Cleanup script for lab-10-rbac
echo "🧹 Cleaning up lab-10-rbac..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-10 2>/dev/null
kubectl delete namespace lab-10 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
