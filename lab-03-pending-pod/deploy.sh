#!/bin/bash
echo "🚀 Deploying Lab 03 - Pending Pod..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 03 deployed! Check: kubectl get pods -n lab-03"
