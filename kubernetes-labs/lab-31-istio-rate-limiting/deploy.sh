#!/bin/bash
set -e

echo "🔧 Deploying Lab 31: Istio Rate Limiting..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 31 deployed!"
echo ""
echo "📋 Scenario: Rate limiting via EnvoyFilter is not working correctly."
echo "   Requests are either not limited or all requests are blocked."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get envoyfilter -n lab-31-ratelimit -o yaml"
echo "   kubectl get configmap -n lab-31-ratelimit -o yaml"
echo "   istioctl proxy-config listeners deploy/api-gateway -n lab-31-ratelimit"
