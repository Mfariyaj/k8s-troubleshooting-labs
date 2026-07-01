#!/bin/bash
echo "🚀 Deploying Lab 06: Resource Exclusion"
kubectl apply -f argocd-cm.yaml
kubectl create namespace resource-exclusion-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd app get resource-exclusion-app"
echo "  argocd app resources resource-exclusion-app"
