#!/bin/bash
# Cleanup script for lab-08-pvc-storageclass
echo "🧹 Cleaning up lab-08-pvc-storageclass..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-08 2>/dev/null
kubectl delete namespace lab-08 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
