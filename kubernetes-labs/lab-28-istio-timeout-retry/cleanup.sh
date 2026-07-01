#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 28: Istio Timeout & Retry..."
kubectl delete namespace lab-28-timeout --ignore-not-found
echo "✅ Lab 28 cleaned up!"
