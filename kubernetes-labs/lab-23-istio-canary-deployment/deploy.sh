#!/bin/bash
set -e

echo "🔧 Deploying Lab 23: Istio Canary Deployment..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 23 deployed!"
echo ""
echo "📋 Scenario: A canary deployment should split traffic 90% to v1 and 10%"
echo "   to v2, but the split isn't working correctly."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-23-canary --show-labels"
echo "   kubectl get virtualservice -n lab-23-canary -o yaml"
echo "   istioctl analyze -n lab-23-canary"
