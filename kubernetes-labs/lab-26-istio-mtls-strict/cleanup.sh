#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 26: Istio mTLS Strict..."
kubectl delete namespace lab-26-mtls --ignore-not-found
echo "✅ Lab 26 cleaned up!"
