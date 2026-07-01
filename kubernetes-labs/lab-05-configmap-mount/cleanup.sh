#!/bin/bash
# Cleanup script for lab-05-configmap-mount
echo "🧹 Cleaning up lab-05-configmap-mount..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-05 2>/dev/null
kubectl delete namespace lab-05 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
