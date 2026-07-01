#!/bin/bash
echo "Cleaning up Lab 14..."
helm uninstall history-overflow --namespace lab14-history 2>/dev/null || true
# Clean up any remaining secrets
kubectl delete secrets -n lab14-history -l owner=helm 2>/dev/null || true
kubectl delete namespace lab14-history 2>/dev/null || true
echo "Cleanup complete."
