#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 27: Istio Gateway TLS..."
kubectl delete namespace lab-27-gateway-tls --ignore-not-found
echo "✅ Lab 27 cleaned up!"
