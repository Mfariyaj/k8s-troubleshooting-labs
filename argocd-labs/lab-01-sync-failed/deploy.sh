#!/bin/bash
echo "🚀 Deploying Lab 01: Sync Failed"
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd app get sync-failed-app"
echo "  argocd app sync sync-failed-app"
