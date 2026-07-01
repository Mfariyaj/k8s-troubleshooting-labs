#!/bin/bash
echo "🚀 Deploying Lab 08: Image Updater"
kubectl create namespace image-updater-lab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f deployment.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Wait a minute, then check:"
echo "  argocd app get image-updater-app"
echo "  kubectl logs -n argocd deployment/argocd-image-updater --tail=20"
