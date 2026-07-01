#!/bin/bash
set -e

echo "🔧 Deploying Lab 21: Istio Sidecar Not Injecting..."
echo ""

# Create namespace
kubectl apply -f namespace.yaml

# Deploy the broken configuration
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 21 deployed!"
echo ""
echo "📋 Scenario: Your web application pods should have Istio sidecar proxies"
echo "   injected automatically, but they are missing."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-21-sidecar"
echo "   kubectl get namespace lab-21-sidecar --show-labels"
echo "   istioctl analyze -n lab-21-sidecar"
