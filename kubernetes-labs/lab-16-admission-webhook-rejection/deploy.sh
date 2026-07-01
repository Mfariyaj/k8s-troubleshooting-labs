#!/bin/bash
set -e

echo "🚀 Deploying Lab 16: Admission Webhook Rejection..."
echo "=================================================="

# Create namespace first
kubectl apply -f namespace.yaml
echo "✅ Namespace created"

# Wait for namespace to be active
sleep 2

# Apply the broken webhook configuration and deployment
kubectl apply -f broken-deployment.yaml
echo "✅ Resources applied"

echo ""
echo "⏳ Waiting for deployment to attempt pod creation..."
sleep 10

echo ""
echo "🔥 Lab 16 is now active!"
echo "=================================================="
echo "SCENARIO: Payment service pods are not starting."
echo "The deployment shows 0/3 replicas ready."
echo ""
echo "Your task: Diagnose why pods cannot be created and fix it."
echo ""
echo "Start with:"
echo "  kubectl get deployments -n lab-16-webhook"
echo "  kubectl describe rs -n lab-16-webhook"
echo "  kubectl get events -n lab-16-webhook"
