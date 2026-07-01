#!/bin/bash
echo "🚀 Deploying Lab 08 - PVC StorageClass..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 08 deployed! Check: kubectl get pvc -n lab-08 && kubectl get pods -n lab-08"
