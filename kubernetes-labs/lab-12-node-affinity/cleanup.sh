#!/bin/bash
# Cleanup script for lab-12-node-affinity
echo "🧹 Cleaning up lab-12-node-affinity..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-12 2>/dev/null
kubectl delete namespace lab-12 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
