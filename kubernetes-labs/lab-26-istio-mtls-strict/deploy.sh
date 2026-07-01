#!/bin/bash
set -e

echo "🔧 Deploying Lab 26: Istio mTLS Strict Mode..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 26 deployed!"
echo ""
echo "📋 Scenario: mTLS strict mode is enabled but some services can't"
echo "   communicate due to sidecar and policy conflicts."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-26-mtls"
echo "   kubectl get peerauthentication -n lab-26-mtls -o yaml"
echo "   kubectl get destinationrule -n lab-26-mtls -o yaml"
echo "   istioctl analyze -n lab-26-mtls"
