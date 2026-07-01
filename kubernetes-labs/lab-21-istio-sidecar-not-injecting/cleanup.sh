#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 21: Istio Sidecar Not Injecting..."
kubectl delete namespace lab-21-sidecar --ignore-not-found
echo "✅ Lab 21 cleaned up!"
