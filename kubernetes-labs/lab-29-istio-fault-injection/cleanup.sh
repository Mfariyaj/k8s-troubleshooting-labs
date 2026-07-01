#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 29: Istio Fault Injection..."
kubectl delete namespace lab-29-fault-injection --ignore-not-found
echo "✅ Lab 29 cleaned up!"
