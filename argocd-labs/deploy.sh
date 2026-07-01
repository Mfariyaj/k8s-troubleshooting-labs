#!/bin/bash
# Deploy all ArgoCD troubleshooting labs
set -e

echo "============================================"
echo "  Deploying All ArgoCD Troubleshooting Labs"
echo "============================================"
echo ""

# Check if argocd CLI is available
if ! command -v argocd &> /dev/null; then
    echo "WARNING: argocd CLI not found. Install it from:"
    echo "  https://argo-cd.readthedocs.io/en/stable/cli_installation/"
    echo ""
fi

# Check if ArgoCD is installed in cluster
if ! kubectl get namespace argocd &> /dev/null; then
    echo "ERROR: ArgoCD namespace not found. Install ArgoCD first:"
    echo "  kubectl create namespace argocd"
    echo "  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LABS=(
    "lab-01-sync-failed"
    "lab-02-health-degraded"
    "lab-03-hook-failure"
    "lab-04-repo-connection"
    "lab-05-app-of-apps"
    "lab-06-resource-exclusion"
    "lab-07-sync-waves"
    "lab-08-image-updater"
    "lab-09-multi-cluster"
    "lab-10-rbac-policy"
)

for lab in "${LABS[@]}"; do
    echo "-------------------------------------------"
    echo "Deploying: $lab"
    echo "-------------------------------------------"
    if [ -f "$SCRIPT_DIR/$lab/deploy.sh" ]; then
        bash "$SCRIPT_DIR/$lab/deploy.sh"
    else
        echo "  SKIP: deploy.sh not found for $lab"
    fi
    echo ""
done

echo "============================================"
echo "  All labs deployed!"
echo "  Use 'argocd app list' to see all apps"
echo "============================================"
