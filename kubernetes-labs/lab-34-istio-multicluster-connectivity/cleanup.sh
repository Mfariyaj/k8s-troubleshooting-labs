#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 34: Istio Multi-Cluster..."
kubectl delete namespace lab-34-multicluster --ignore-not-found
echo "✅ Lab 34 cleaned up!"
