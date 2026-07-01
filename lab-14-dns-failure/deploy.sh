#!/bin/bash
echo "🚀 Deploying Lab 14 - DNS Failure..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 14 deployed! Check: kubectl get pods -n lab-14 && kubectl get svc -n lab-14"
