#!/bin/bash
set -e

echo "============================================"
echo "Lab 15: Helm Diff False Positives"
echo "============================================"
echo ""

cd "$(dirname "$0")"

NAMESPACE="lab15-diff"

echo "Step 1: Creating namespace and installing chart..."
kubectl create namespace $NAMESPACE 2>/dev/null || true

helm install myapp ./mychart --namespace $NAMESPACE

echo ""
echo "Step 2: Waiting for deployment to be ready..."
kubectl rollout status deployment/myapp-mychart -n $NAMESPACE --timeout=60s 2>/dev/null || true

echo ""
echo "Step 3: Simulating server-side mutations..."
echo "  - Adding admission controller annotations"
echo "  - Simulating VPA resource modification"
echo ""

# Simulate admission controller annotations
kubectl annotate deployment myapp-mychart -n $NAMESPACE \
  deployment.kubernetes.io/revision="3" \
  --overwrite 2>/dev/null || true

kubectl annotate pods -l app.kubernetes.io/name=mychart -n $NAMESPACE \
  cni.projectcalico.org/podIPs="10.244.1.15/32" \
  sidecar.istio.io/status='{"initContainers":["istio-init"],"containers":["istio-proxy"]}' \
  2>/dev/null || true

# Simulate VPA modifying resource requests
kubectl patch deployment myapp-mychart -n $NAMESPACE --type=json \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value": "250m"},{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value": "500m"}]' \
  2>/dev/null || true

echo ""
echo "Step 4: Running helm diff (should show false positives)..."
echo ""
echo "Running: helm diff upgrade myapp ./mychart --namespace $NAMESPACE"
helm diff upgrade myapp ./mychart --namespace $NAMESPACE 2>&1 || true

echo ""
echo "============================================"
echo "If helm-diff shows changes despite no actual chart changes,"
echo "your task is to eliminate the false positives!"
echo ""
echo "Try these and observe the diffs:"
echo "  helm diff upgrade myapp ./mychart --namespace $NAMESPACE"
echo "  helm diff upgrade myapp ./mychart --namespace $NAMESPACE --normalize-manifests"
echo "  helm diff upgrade myapp ./mychart --namespace $NAMESPACE --three-way-merge"
echo "============================================"
