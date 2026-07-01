#!/bin/bash
echo "Cleaning up Lab 11..."
helm uninstall myapp --namespace lab11-postrenderer 2>/dev/null || true
kubectl delete namespace lab11-postrenderer 2>/dev/null || true
rm -f kustomize/rendered.yaml kustomize/output.yaml /tmp/kustomize-output.yaml
echo "Cleanup complete."
