#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 24: Istio Blue-Green Deployment..."
kubectl delete namespace lab-24-bluegreen --ignore-not-found
echo "✅ Lab 24 cleaned up!"
