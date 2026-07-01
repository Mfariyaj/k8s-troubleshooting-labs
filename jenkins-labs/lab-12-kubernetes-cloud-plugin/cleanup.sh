#!/bin/bash
set -e

echo "Cleaning up Lab 12: Kubernetes Cloud Plugin..."

cd "$(dirname "$0")"

docker compose down -v 2>/dev/null || true
docker rm -f jenkins-k8s-lab 2>/dev/null || true

# Clean up any K8s resources if cluster is available
kubectl delete -f pod-template.yaml --ignore-not-found 2>/dev/null || true

echo "Lab 12 cleaned up successfully."
