#!/bin/bash
echo "🚀 Deploying Lab 10 - RBAC..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 10 deployed! Check: kubectl get pods -n lab-10 && kubectl logs -n lab-10 -l app=controller-app"
