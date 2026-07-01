#!/bin/bash
echo "🚀 Deploying Lab 07: Sync Waves"
kubectl create namespace sync-waves-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f manifests/
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd app get sync-waves-app"
echo "  kubectl get pods -n sync-waves-lab"
