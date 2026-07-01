#!/bin/bash
# Lab 04: Cleanup
echo "=== Cleaning up Lab 04: Hook Weight Ordering ==="
helm uninstall myrelease 2>/dev/null || echo "No release to uninstall"
kubectl delete job -l app.kubernetes.io/managed-by=Helm 2>/dev/null
echo "Done."
