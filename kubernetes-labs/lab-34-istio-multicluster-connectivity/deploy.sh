#!/bin/bash
set -e

echo "🔧 Deploying Lab 34: Istio Multi-Cluster Connectivity..."
echo ""

kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml

echo ""
echo "✅ Lab 34 deployed!"
echo ""
echo "📋 Scenario: Multi-cluster Istio setup is broken. Services in the"
echo "   remote cluster are not discoverable from this cluster."
echo ""
echo "🔍 Start investigating:"
echo "   kubectl get serviceentry -n lab-34-multicluster -o yaml"
echo "   kubectl get destinationrule -n lab-34-multicluster -o yaml"
echo "   kubectl get gateway -n lab-34-multicluster -o yaml"
echo "   istioctl analyze -n lab-34-multicluster"
