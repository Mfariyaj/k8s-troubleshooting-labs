#!/bin/bash
echo "🧹 Cleaning up Lab 03: Service Discovery RBAC..."
cd "$(dirname "$0")"
kubectl delete -f rbac.yaml --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
echo "✅ Lab 03 cleaned up."
