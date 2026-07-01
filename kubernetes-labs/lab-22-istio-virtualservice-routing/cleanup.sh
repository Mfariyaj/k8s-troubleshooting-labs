#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 22: Istio VirtualService Routing..."
kubectl delete namespace lab-22-routing --ignore-not-found
echo "✅ Lab 22 cleaned up!"
