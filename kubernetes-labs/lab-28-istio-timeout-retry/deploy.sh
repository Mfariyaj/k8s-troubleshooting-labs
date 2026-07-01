#!/bin/bash
set -e

echo "🔧 Deploying Lab 28: Istio Timeout & Retry Misconfiguration..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 28 deployed!"
echo ""
echo "📋 Scenario: Timeout and retry policies are misconfigured, causing"
echo "   premature failures and retry storms."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get virtualservice -n lab-28-timeout -o yaml"
echo "   istioctl analyze -n lab-28-timeout"
echo "   istioctl proxy-config routes deploy/order-service -n lab-28-timeout"
