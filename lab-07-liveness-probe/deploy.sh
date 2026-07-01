#!/bin/bash
echo "🚀 Deploying Lab 07 - Liveness Probe..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 07 deployed! Check: kubectl get pods -n lab-07 -w"
