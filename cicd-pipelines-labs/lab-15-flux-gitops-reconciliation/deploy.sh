#!/bin/bash
set -e

echo "============================================"
echo "Lab 15: Flux CD GitOps Reconciliation Stuck"
echo "============================================"
echo ""
echo "This lab deploys a broken Flux CD configuration"
echo "where GitOps reconciliation is stuck/failing."
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
  echo "WARNING: kubectl not found."
  echo "This lab requires a Kubernetes cluster with Flux CD installed."
  echo ""
  echo "To install Flux:"
  echo "  flux install"
  echo ""
  echo "For now, examine the files manually:"
  echo "  cat flux-system/gitrepository.yaml"
  echo "  cat flux-system/kustomization.yaml"
  echo "  cat flux-system/helmrelease.yaml"
  exit 0
fi

# Check if Flux is installed
if ! kubectl get crd kustomizations.kustomize.toolkit.fluxcd.io &> /dev/null 2>&1; then
  echo "WARNING: Flux CRDs not found in cluster."
  echo "Install Flux first: flux install"
  echo ""
  echo "For now, examine the files manually:"
  echo "  cat flux-system/gitrepository.yaml"
  echo "  cat flux-system/kustomization.yaml"
  echo "  cat flux-system/helmrelease.yaml"
  exit 0
fi

echo "Creating flux-system namespace (if not exists)..."
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Deploying broken Flux resources..."
kubectl apply -f flux-system/gitrepository.yaml
kubectl apply -f flux-system/helmrelease.yaml
kubectl apply -f flux-system/kustomization.yaml

echo ""
echo "============================================"
echo "Lab deployed! Flux reconciliation will fail."
echo ""
echo "Investigate with:"
echo "  flux get sources git -n flux-system"
echo "  flux get kustomizations -n flux-system"
echo "  flux get helmreleases -n flux-system"
echo "  kubectl describe kustomization app-production -n flux-system"
echo "============================================"
