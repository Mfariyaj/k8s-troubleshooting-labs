#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 31: Istio Rate Limiting..."
kubectl delete namespace lab-31-ratelimit --ignore-not-found
echo "✅ Lab 31 cleaned up!"
