#!/bin/bash
echo "Cleaning up Lab 15..."
helm uninstall myapp --namespace lab15-diff 2>/dev/null || true
kubectl delete namespace lab15-diff 2>/dev/null || true
echo "Cleanup complete."
