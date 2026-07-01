#!/bin/bash
set -e

echo "============================================"
echo "Lab 14: Tekton Pipeline DAG"
echo "============================================"
echo ""
echo "This lab deploys a broken Tekton Pipeline with"
echo "DAG ordering, workspace, and result-passing issues."
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
  echo "WARNING: kubectl not found."
  echo "This lab requires a Kubernetes cluster with Tekton installed."
  echo ""
  echo "To install Tekton Pipelines:"
  echo "  kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"
  echo ""
  echo "For now, examine the files manually:"
  echo "  cat pipeline.yaml"
  echo "  cat tasks/build-task.yaml"
  echo "  cat tasks/deploy-task.yaml"
  echo "  cat pipelinerun.yaml"
  exit 0
fi

# Check if Tekton is installed
if ! kubectl get crd pipelines.tekton.dev &> /dev/null; then
  echo "WARNING: Tekton Pipelines CRDs not found in cluster."
  echo "Install Tekton first:"
  echo "  kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"
  exit 1
fi

echo "Creating namespace..."
kubectl create namespace ci --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Deploying Tekton Tasks..."
kubectl apply -f tasks/ -n ci

echo ""
echo "Deploying Pipeline..."
kubectl apply -f pipeline.yaml -n ci

echo ""
echo "Creating PipelineRun..."
kubectl apply -f pipelinerun.yaml -n ci

echo ""
echo "============================================"
echo "Lab deployed! The PipelineRun will fail."
echo ""
echo "Investigate with:"
echo "  tkn pipelinerun describe build-deploy-run-001 -n ci"
echo "  kubectl describe pipelinerun build-deploy-run-001 -n ci"
echo "  kubectl get events -n ci --sort-by='.lastTimestamp'"
echo "============================================"
