#!/bin/bash
# Lab 06: Conditional Rendering Produces Empty YAML Documents
# This demonstrates the "---" empty document issue

echo "=== Lab 06: Conditional Empty Documents ==="
echo ""
echo "Running: helm template myrelease ./mychart --debug"
echo ""

cd "$(dirname "$0")"
helm template myrelease ./mychart --debug

echo ""
echo "Running: helm install myrelease ./mychart --dry-run --debug 2>&1 | tail -20"
echo ""
helm install myrelease ./mychart --dry-run --debug 2>&1 | tail -20

echo ""
echo "❌ When monitoring.enabled=false, the servicemonitor.yaml produces an empty YAML"
echo "   document (just '---'), which can cause errors with kubectl apply and some tools."
