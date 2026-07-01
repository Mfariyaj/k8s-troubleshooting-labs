#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 35: Istio Observability..."
kubectl delete namespace lab-35-observability --ignore-not-found
echo "✅ Lab 35 cleaned up!"
