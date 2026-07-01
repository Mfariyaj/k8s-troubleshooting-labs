#!/bin/bash
# Cleanup script for lab-02-imagepullbackoff
echo "🧹 Cleaning up lab-02-imagepullbackoff..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-02 2>/dev/null
kubectl delete namespace lab-02 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
