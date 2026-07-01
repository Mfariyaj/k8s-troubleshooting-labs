#!/bin/bash
set -e

echo "============================================"
echo "Lab 11: Helm Post-Renderer with Kustomize"
echo "============================================"
echo ""
echo "Deploying chart with post-renderer..."
echo ""

cd "$(dirname "$0")"

# Attempt to install with post-renderer
echo "Running: helm install myapp ./mychart --post-renderer ./post-render.sh --namespace lab11-postrenderer --create-namespace"
helm install myapp ./mychart \
  --post-renderer ./post-render.sh \
  --namespace lab11-postrenderer \
  --create-namespace

echo ""
echo "If you see errors above, your task is to fix the post-renderer pipeline!"
echo ""
echo "Expected outcome:"
echo "  - Helm renders the chart"
echo "  - post-render.sh receives the YAML via stdin"
echo "  - Kustomize applies patches (sidecar injection, resource changes)"
echo "  - Final patched YAML is output to stdout"
echo "  - Helm applies the patched YAML to the cluster"
