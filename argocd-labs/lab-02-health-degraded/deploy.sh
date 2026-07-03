#!/bin/bash
echo "🚀 Deploying Lab 02: Health Degraded"
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait 20-30 seconds, then check:"
echo "  argocd app get health-degraded-app"
echo "  kubectl get pods -n health-degraded-lab"
echo ""
echo "📋 Expected on ArgoCD dashboard: Health Status = Degraded"
echo "🔍 Your task: Find and fix the broken image tag"
