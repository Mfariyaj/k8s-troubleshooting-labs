#!/bin/bash
echo "🚀 Deploying Lab 05 - ConfigMap Mount..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 05 deployed! Check: kubectl get pods -n lab-05"
