#!/bin/bash
echo "🚀 Deploying Lab 13 - HPA Metrics..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 13 deployed! Check: kubectl get hpa -n lab-13 && kubectl get pods -n lab-13"
