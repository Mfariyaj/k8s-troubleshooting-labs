#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 25: Istio Circuit Breaker..."
kubectl delete namespace lab-25-circuitbreaker --ignore-not-found
echo "✅ Lab 25 cleaned up!"
