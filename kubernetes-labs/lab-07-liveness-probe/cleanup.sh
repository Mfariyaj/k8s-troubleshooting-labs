#!/bin/bash
# Cleanup script for lab-07-liveness-probe
echo "🧹 Cleaning up lab-07-liveness-probe..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-07 2>/dev/null
kubectl delete namespace lab-07 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
