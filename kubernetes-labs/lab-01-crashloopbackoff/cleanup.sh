#!/bin/bash
# Cleanup script for lab-01-crashloopbackoff
echo "🧹 Cleaning up lab-01-crashloopbackoff..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-01 2>/dev/null
kubectl delete namespace lab-01 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
