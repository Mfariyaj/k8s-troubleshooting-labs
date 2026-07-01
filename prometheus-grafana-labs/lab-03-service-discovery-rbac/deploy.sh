#!/bin/bash
echo "🚀 Deploying Lab 03: Service Discovery RBAC..."
cd "$(dirname "$0")"

# Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy RBAC and Prometheus
kubectl apply -f rbac.yaml

echo ""
echo "✅ Lab deployed! Prometheus is running in the 'monitoring' namespace."
echo "🔍 Port-forward to access: kubectl port-forward -n monitoring deploy/prometheus 9090:9090"
echo "❌ You should see service discovery errors - no targets discovered"
echo ""
echo "Your task: Fix the RBAC permissions so Prometheus can discover Kubernetes pods and services."
