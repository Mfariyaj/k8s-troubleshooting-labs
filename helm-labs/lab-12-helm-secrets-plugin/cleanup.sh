#!/bin/bash
echo "Cleaning up Lab 12..."
helm uninstall myapp --namespace lab12-secrets 2>/dev/null || true
kubectl delete namespace lab12-secrets 2>/dev/null || true
echo "Cleanup complete."
