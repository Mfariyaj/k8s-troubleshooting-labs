#!/bin/bash
echo "🚀 Deploying Lab 02: Health Degraded"

# Create the namespace
kubectl create namespace health-degraded-lab --dry-run=client -o yaml | kubectl apply -f -

# Deploy the broken deployment directly (bad image: nginx:nonexistent)
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo ""
echo "⏳ Wait 15-20 seconds for pods to fail, then check:"
echo ""
echo "  kubectl get pods -n health-degraded-lab"
echo "  kubectl describe pod -n health-degraded-lab"
echo "  argocd app get health-degraded-app  (if ArgoCD app was created)"
echo ""
echo "📋 Expected: Pods stuck in ImagePullBackOff (image nginx:nonexistent doesn't exist)"
echo "🔍 Your task: Fix the image tag in deployment.yaml and re-apply"
