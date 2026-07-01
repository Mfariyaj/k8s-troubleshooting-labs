#!/bin/bash
echo "🧹 Cleaning up Lab 05: App of Apps"
kubectl delete -f apps/child-app-1.yaml --ignore-not-found
kubectl delete -f apps/child-app-2.yaml --ignore-not-found
kubectl delete -f parent-app.yaml --ignore-not-found
kubectl delete namespace child-ns-1 --ignore-not-found
kubectl delete namespace child-ns-2 --ignore-not-found
echo "✅ Cleanup complete"
