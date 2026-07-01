#!/bin/bash
set -e

echo "============================================"
echo "Lab 14: Cleanup"
echo "============================================"
echo ""

if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found — nothing to clean up."
  exit 0
fi

echo "Deleting Tekton resources..."
kubectl delete pipelinerun build-deploy-run-001 -n ci --ignore-not-found
kubectl delete pipeline build-deploy-pipeline -n ci --ignore-not-found
kubectl delete task kaniko kubectl-deploy cleanup-workspace -n ci --ignore-not-found
kubectl delete pvc pipeline-workspace-pvc -n ci --ignore-not-found

echo ""
echo "Lab 14 cleanup complete."
