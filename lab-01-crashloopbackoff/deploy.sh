#!/bin/bash
echo "🚀 Deploying Lab 01 - CrashLoopBackOff..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 01 deployed! Check: kubectl get pods -n lab-01"
