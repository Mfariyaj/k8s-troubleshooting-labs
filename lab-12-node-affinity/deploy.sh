#!/bin/bash
echo "🚀 Deploying Lab 12 - Node Affinity..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 12 deployed! Check: kubectl get pods -n lab-12"
