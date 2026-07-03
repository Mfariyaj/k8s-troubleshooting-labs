#!/bin/bash
# =============================================================================
# ArgoCD Installation Script
# =============================================================================
# Run this ONCE before using any ArgoCD labs.
# Prerequisites: kubectl configured and connected to a Kubernetes cluster.
#
# Usage: ./install-argocd.sh
# =============================================================================

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║   🚀 ArgoCD Installation for Labs               ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Check kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found! Install it first:"
    echo "   https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster!"
    echo "   Make sure your cluster is running and kubectl is configured."
    echo "   Try: minikube start / kind create cluster / check your kubeconfig"
    exit 1
fi

echo "✅ Kubernetes cluster connected"
echo ""

# Check if ArgoCD is already installed
if kubectl get namespace argocd &> /dev/null; then
    echo "⚠️  ArgoCD namespace already exists!"
    PODS_READY=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    if [ "$PODS_READY" -ge 5 ]; then
        echo "✅ ArgoCD is already running ($PODS_READY pods ready)"
        echo ""
        echo "Admin password:"
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d
        echo ""
        echo ""
        echo "Access: kubectl port-forward svc/argocd-server -n argocd 8443:443"
        echo "URL:    https://localhost:8443"
        echo "User:   admin"
        exit 0
    fi
    echo "   ArgoCD namespace exists but pods are not all running. Reinstalling..."
fi

# Step 1: Create namespace
echo "📦 Step 1/5: Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Step 2: Install ArgoCD
echo "📦 Step 2/5: Installing ArgoCD (latest stable)..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Step 3: Wait for pods
echo "⏳ Step 3/5: Waiting for ArgoCD pods to be ready (this takes 1-3 minutes)..."
echo "   Watching pods..."
for i in $(seq 1 60); do
    READY=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    TOTAL=$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l)
    printf "\r   Pods ready: $READY/$TOTAL"
    if [ "$READY" -ge 5 ] && [ "$READY" -eq "$TOTAL" ]; then
        echo ""
        echo "   ✅ All pods running!"
        break
    fi
    sleep 5
done

# Step 4: Get admin password
echo ""
echo "🔑 Step 4/5: Getting admin credentials..."
ADMIN_PASS=""
for i in $(seq 1 12); do
    ADMIN_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null)
    if [ -n "$ADMIN_PASS" ]; then
        break
    fi
    sleep 5
done

# Step 5: Print access info
echo "🌐 Step 5/5: Setup complete!"
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   ✅ ArgoCD Installed Successfully!              ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║   To access ArgoCD Dashboard:                    ║"
echo "║                                                  ║"
echo "║   1. Run in a separate terminal:                 ║"
echo "║      kubectl port-forward svc/argocd-server \    ║"
echo "║        -n argocd 8443:443                        ║"
echo "║                                                  ║"
echo "║   2. Open in browser:                            ║"
echo "║      https://localhost:8443                      ║"
echo "║                                                  ║"
echo "║   3. Login credentials:                          ║"
echo "║      Username: admin                             ║"
printf "║      Password: %-33s║\n" "$ADMIN_PASS"
echo "║                                                  ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║   Now you can run any ArgoCD lab:                ║"
echo "║      cd lab-01-sync-failed && ./deploy.sh        ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Optional: Install argocd CLI
echo "💡 Optional: Install ArgoCD CLI for debugging:"
echo "   curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "   chmod +x /usr/local/bin/argocd"
echo "   argocd login localhost:8443 --username admin --password $ADMIN_PASS --insecure"
