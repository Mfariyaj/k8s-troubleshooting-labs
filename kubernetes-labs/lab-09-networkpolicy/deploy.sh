#!/bin/bash
echo "🚀 Deploying Lab 09 - NetworkPolicy..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 09 deployed! Check: kubectl get pods -n lab-09 && kubectl get networkpolicy -n lab-09"
