#!/bin/bash
set -e

echo "🔧 Deploying Lab 27: Istio Gateway TLS Termination..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 27 deployed!"
echo ""
echo "📋 Scenario: TLS termination at Istio ingress gateway is failing with"
echo "   503 errors and certificate issues."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get gateway -n lab-27-gateway-tls -o yaml"
echo "   kubectl get virtualservice -n lab-27-gateway-tls -o yaml"
echo "   kubectl get secrets -n lab-27-gateway-tls"
echo "   kubectl get secrets -n istio-system | grep tls"
echo "   istioctl analyze -n lab-27-gateway-tls"
