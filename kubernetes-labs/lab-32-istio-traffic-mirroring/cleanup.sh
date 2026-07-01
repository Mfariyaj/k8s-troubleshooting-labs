#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 32: Istio Traffic Mirroring..."
kubectl delete namespace lab-32-mirroring --ignore-not-found
echo "✅ Lab 32 cleaned up!"
