#!/bin/bash
echo "🚀 Deploying Lab 06 - Missing Secret..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 06 deployed! Check: kubectl get pods -n lab-06"
