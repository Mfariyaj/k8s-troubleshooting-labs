#!/bin/bash
set -e

echo "🔧 Deploying Lab 24: Istio Blue-Green Deployment..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 24 deployed!"
echo ""
echo "📋 Scenario: A blue-green deployment switch should route all traffic to"
echo "   the new 'green' version, but blue pods still receive traffic."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-24-bluegreen --show-labels"
echo "   kubectl get virtualservice -n lab-24-bluegreen -o yaml"
echo "   kubectl get destinationrule -n lab-24-bluegreen -o yaml"
echo "   istioctl analyze -n lab-24-bluegreen"
