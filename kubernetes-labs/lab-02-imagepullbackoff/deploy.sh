#!/bin/bash
echo "🚀 Deploying Lab 02 - ImagePullBackOff..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 02 deployed! Check: kubectl get pods -n lab-02"
