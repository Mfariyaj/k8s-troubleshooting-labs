#!/bin/bash
echo "🚀 Deploying Lab 11 - Init Container..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 11 deployed! Check: kubectl get pods -n lab-11"
