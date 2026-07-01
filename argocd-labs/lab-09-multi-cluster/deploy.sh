#!/bin/bash
echo "🚀 Deploying Lab 09: Multi-Cluster"
kubectl apply -f cluster-secret.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd cluster list"
echo "  argocd app get multi-cluster-app"
