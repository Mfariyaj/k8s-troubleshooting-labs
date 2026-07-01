#!/bin/bash
# Cleanup script for lab-09-networkpolicy
echo "🧹 Cleaning up lab-09-networkpolicy..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-09 2>/dev/null
kubectl delete namespace lab-09 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
