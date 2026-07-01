#!/bin/bash
# Deploy all 15 troubleshooting labs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Deploying all 15 Kubernetes Troubleshooting Labs..."
echo "======================================================="

for lab_dir in "$SCRIPT_DIR"/lab-*/; do
  lab_name=$(basename "$lab_dir")
  echo ""
  echo "📦 Deploying: $lab_name"
  
  if [ -f "$lab_dir/namespace.yaml" ]; then
    kubectl apply -f "$lab_dir/namespace.yaml"
  fi
  
  if [ -f "$lab_dir/broken-deployment.yaml" ]; then
    kubectl apply -f "$lab_dir/broken-deployment.yaml"
  fi
  
  echo "   ✅ $lab_name deployed"
done

echo ""
echo "======================================================="
echo "🎯 All 15 labs deployed! Open another terminal and start troubleshooting."
echo ""
echo "Start with: kubectl get pods --all-namespaces | grep -v Running"
echo ""
