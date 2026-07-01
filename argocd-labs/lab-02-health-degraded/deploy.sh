#!/bin/bash
echo "🚀 Deploying Lab 02: Health Degraded"
kubectl create namespace health-degraded-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd app get health-degraded-app"
echo "  kubectl get pods -n health-degraded-lab"
