#!/bin/bash
# Cleanup script for lab-13-hpa-metrics
echo "🧹 Cleaning up lab-13-hpa-metrics..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-13 2>/dev/null
kubectl delete namespace lab-13 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
