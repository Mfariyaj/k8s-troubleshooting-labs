#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 23: Istio Canary Deployment..."
kubectl delete namespace lab-23-canary --ignore-not-found
echo "✅ Lab 23 cleaned up!"
