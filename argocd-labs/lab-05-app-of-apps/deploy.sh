#!/bin/bash
echo "🚀 Deploying Lab 05: App of Apps"
kubectl apply -f parent-app.yaml
kubectl apply -f apps/child-app-1.yaml
kubectl apply -f apps/child-app-2.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd app list"
echo "  argocd app get child-app-2"
