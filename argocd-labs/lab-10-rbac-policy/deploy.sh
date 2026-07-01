#!/bin/bash
echo "🚀 Deploying Lab 10: RBAC Policy"
kubectl apply -f argocd-rbac-cm.yaml
kubectl apply -f appproject.yaml
kubectl apply -f application.yaml
echo ""
echo "⏳ Check RBAC and attempt sync:"
echo "  kubectl get cm argocd-rbac-cm -n argocd -o yaml"
echo "  argocd app sync rbac-test-app"
echo "  argocd admin settings rbac can role:developer sync applications team-project/rbac-test-app"
