#!/bin/bash
set -e

echo "🔧 Deploying Lab 25: Istio Circuit Breaker..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 25 deployed!"
echo ""
echo "📋 Scenario: Circuit breaker should trip and stop sending traffic to"
echo "   failing pods, but unhealthy pods keep receiving requests."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get pods -n lab-25-circuitbreaker"
echo "   kubectl get destinationrule -n lab-25-circuitbreaker -o yaml"
echo "   istioctl proxy-config clusters deploy/payment-service -n lab-25-circuitbreaker"
