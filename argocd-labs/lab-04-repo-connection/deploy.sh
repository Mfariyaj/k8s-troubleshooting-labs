#!/bin/bash
echo "🚀 Deploying Lab 04: Repo Connection Failure"
kubectl apply -f repo-secret.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a few seconds, then check:"
echo "  argocd repo list"
echo "  argocd app get repo-connection-app"
