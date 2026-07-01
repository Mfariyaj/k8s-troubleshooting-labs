#!/bin/bash
# Cleanup script for lab-04-service-selector-mismatch
echo "🧹 Cleaning up lab-04-service-selector-mismatch..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-04 2>/dev/null
kubectl delete namespace lab-04 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
