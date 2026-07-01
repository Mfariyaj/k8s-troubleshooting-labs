#!/bin/bash
echo "🚀 Deploying Lab 04 - Service Selector Mismatch..."
kubectl apply -f namespace.yaml
kubectl apply -f broken-deployment.yaml
echo "✅ Lab 04 deployed! Check: kubectl get pods -n lab-04 && kubectl get endpoints -n lab-04"
