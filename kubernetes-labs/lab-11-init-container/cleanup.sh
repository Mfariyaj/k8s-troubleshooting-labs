#!/bin/bash
# Cleanup script for lab-11-init-container
echo "🧹 Cleaning up lab-11-init-container..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-11 2>/dev/null
kubectl delete namespace lab-11 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
