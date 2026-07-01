#!/bin/bash
# Cleanup script for lab-06-missing-secret
echo "🧹 Cleaning up lab-06-missing-secret..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-06 2>/dev/null
kubectl delete namespace lab-06 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
