#!/bin/bash
echo "🧹 Cleaning up Lab 09: Multi-Cluster"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f cluster-secret.yaml --ignore-not-found
kubectl delete namespace multi-cluster-lab --ignore-not-found
echo "✅ Cleanup complete"
