#!/bin/bash
echo "🚀 Deploying Lab 15 - Rolling Update..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 15 deployed! Check: kubectl get pods -n lab-15 && kubectl rollout status deployment/payment-service -n lab-15"
