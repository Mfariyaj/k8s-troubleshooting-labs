#!/bin/bash
set -e

echo "🔧 Deploying Lab 29: Istio Fault Injection..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 29 deployed!"
echo ""
echo "📋 Scenario: Fault injection for chaos testing should only affect test"
echo "   traffic, but it's either not working or affecting all traffic."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get virtualservice -n lab-29-fault-injection -o yaml"
echo "   istioctl analyze -n lab-29-fault-injection"
