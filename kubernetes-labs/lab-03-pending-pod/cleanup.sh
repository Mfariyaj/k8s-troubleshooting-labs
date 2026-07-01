#!/bin/bash
# Cleanup script for lab-03-pending-pod
echo "🧹 Cleaning up lab-03-pending-pod..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-03 2>/dev/null
kubectl delete namespace lab-03 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
