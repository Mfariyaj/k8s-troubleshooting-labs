#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 30: Istio Authorization Policy..."
kubectl delete namespace lab-30-authz --ignore-not-found
echo "✅ Lab 30 cleaned up!"
