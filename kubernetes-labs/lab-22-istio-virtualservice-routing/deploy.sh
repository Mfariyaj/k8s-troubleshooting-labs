#!/bin/bash
set -e

echo "🔧 Deploying Lab 22: Istio VirtualService Routing..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 22 deployed!"
echo ""
echo "📋 Scenario: VirtualService routing rules should route header-based"
echo "   traffic to v2 and all other traffic to v1, but routing is broken."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-22-routing"
echo "   kubectl get virtualservice -n lab-22-routing"
echo "   istioctl analyze -n lab-22-routing"
