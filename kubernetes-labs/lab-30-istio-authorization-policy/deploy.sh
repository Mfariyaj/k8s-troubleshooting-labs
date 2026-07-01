#!/bin/bash
set -e

echo "🔧 Deploying Lab 30: Istio Authorization Policy..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 30 deployed!"
echo ""
echo "📋 Scenario: AuthorizationPolicy is blocking legitimate traffic."
echo "   Requests from frontend to backend are denied."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get authorizationpolicy -n lab-30-authz -o yaml"
echo "   kubectl exec deploy/frontend -n lab-30-authz -- curl -s http://backend-api"
echo "   istioctl analyze -n lab-30-authz"
