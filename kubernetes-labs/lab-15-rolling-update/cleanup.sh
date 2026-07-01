#!/bin/bash
# Cleanup script for lab-15-rolling-update
echo "🧹 Cleaning up lab-15-rolling-update..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-15 2>/dev/null
kubectl delete namespace lab-15 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
