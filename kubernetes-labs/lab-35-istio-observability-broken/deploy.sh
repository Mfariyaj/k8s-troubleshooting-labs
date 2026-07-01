#!/bin/bash
set -e

echo "🔧 Deploying Lab 35: Istio Observability Broken..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 35 deployed!"
echo ""
echo "📋 Scenario: Istio observability stack is broken. No metrics in Prometheus,"
echo "   no traces in Jaeger, and Kiali shows empty service graph."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get telemetry -n lab-35-observability -o yaml"
echo "   kubectl get servicemonitor -n lab-35-observability -o yaml"
echo "   kubectl get configmap -n lab-35-observability -o yaml"
echo "   istioctl analyze -n lab-35-observability"
