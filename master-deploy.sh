#!/bin/bash
# Master Deploy Script - DevOps Troubleshooting Labs
# Deploys labs for a specific tool category or all categories

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_usage() {
    echo "Usage: $0 [CATEGORY]"
    echo ""
    echo "Categories:"
    echo "  k8s              - Kubernetes labs (15 labs)"
    echo "  terraform        - Terraform labs (10 labs)"
    echo "  docker           - Docker labs (10 labs)"
    echo "  ansible          - Ansible labs (10 labs)"
    echo "  jenkins          - Jenkins labs (10 labs)"
    echo "  argocd           - ArgoCD labs (10 labs)"
    echo "  prometheus       - Prometheus/Grafana labs (10 labs)"
    echo "  helm             - Helm labs (10 labs)"
    echo "  linux            - Linux/Networking labs (10 labs)"
    echo "  nginx            - Nginx/HAProxy labs (10 labs)"
    echo "  cicd             - CI/CD Pipelines labs (10 labs)"
    echo "  all              - All categories"
    echo ""
    echo "Example: $0 docker"
}

deploy_category() {
    local category=$1
    local dir=""
    
    case $category in
        k8s|kubernetes)
            dir="$BASE_DIR/kubernetes-labs"
            ;;
        terraform)
            dir="$BASE_DIR/terraform-labs"
            ;;
        docker)
            dir="$BASE_DIR/docker-labs"
            ;;
        ansible)
            dir="$BASE_DIR/ansible-labs"
            ;;
        jenkins)
            dir="$BASE_DIR/jenkins-labs"
            ;;
        argocd)
            dir="$BASE_DIR/argocd-labs"
            ;;
        prometheus|grafana|prometheus-grafana)
            dir="$BASE_DIR/prometheus-grafana-labs"
            ;;
        helm)
            dir="$BASE_DIR/helm-labs"
            ;;
        linux|networking|linux-networking)
            dir="$BASE_DIR/linux-networking-labs"
            ;;
        nginx|haproxy|nginx-haproxy)
            dir="$BASE_DIR/nginx-haproxy-labs"
            ;;
        cicd|pipelines|cicd-pipelines)
            dir="$BASE_DIR/cicd-pipelines-labs"
            ;;
        *)
            echo "❌ Unknown category: $category"
            show_usage
            exit 1
            ;;
    esac
    
    if [ -n "$dir" ]; then
        echo "🚀 Deploying $category labs from $dir..."
        if [ -f "$dir/deploy.sh" ]; then
            cd "$dir" && bash deploy.sh
        elif [ -f "$dir/deploy-all.sh" ]; then
            cd "$dir" && bash deploy-all.sh
        else
            echo "⚠️  No deploy script found in $dir"
        fi
    fi
    
    echo "✅ $category labs deployed!"
}

if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

if [ "$1" = "all" ]; then
    for cat in terraform docker ansible jenkins argocd prometheus helm linux nginx cicd; do
        deploy_category "$cat"
        echo ""
    done
    echo "🎉 All labs deployed!"
else
    deploy_category "$1"
fi
