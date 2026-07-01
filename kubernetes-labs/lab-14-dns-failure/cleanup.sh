#!/bin/bash
# Cleanup script for lab-14-dns-failure
echo "🧹 Cleaning up lab-14-dns-failure..."
kubectl delete -f broken-deployment.yaml --ignore-not-found -n lab-14 2>/dev/null
kubectl delete namespace lab-14 --ignore-not-found 2>/dev/null
echo "✅ Cleanup complete!"
