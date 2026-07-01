#!/bin/bash
set -e

echo "🔧 Deploying Lab 33: Istio ServiceEntry for External Services..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 33 deployed!"
echo ""
echo "📋 Scenario: Applications need to reach an external API but traffic"
echo "   is being blocked by misconfigured ServiceEntry and egress rules."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get serviceentry -n lab-33-serviceentry -o yaml"
echo "   kubectl get sidecar -n lab-33-serviceentry -o yaml"
echo "   kubectl exec deploy/app-service -n lab-33-serviceentry -- curl -v https://api.external-service.com"
echo "   istioctl analyze -n lab-33-serviceentry"
