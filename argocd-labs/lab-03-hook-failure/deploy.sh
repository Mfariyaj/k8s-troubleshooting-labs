#!/bin/bash
echo "🚀 Deploying Lab 03: Hook Failure"
kubectl create namespace hook-failure-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f application.yaml
kubectl apply -f hooks/pre-sync-job.yaml
echo ""
echo "⏳ Now trigger a sync:"
echo "  argocd app sync hook-failure-app"
echo "  argocd app get hook-failure-app"
