#!/bin/bash
set -e

echo "🔧 Deploying Lab 32: Istio Traffic Mirroring..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 32 deployed!"
echo ""
echo "📋 Scenario: Traffic mirroring should shadow 100% of v1 traffic to v2"
echo "   for testing, but mirrored requests never reach v2."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get virtualservice -n lab-32-mirroring -o yaml"
echo "   kubectl get destinationrule -n lab-32-mirroring -o yaml"
echo "   istioctl analyze -n lab-32-mirroring"
