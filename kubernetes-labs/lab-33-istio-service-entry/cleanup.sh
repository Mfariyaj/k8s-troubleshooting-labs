#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 33: Istio ServiceEntry..."
kubectl delete namespace lab-33-serviceentry --ignore-not-found
echo "✅ Lab 33 cleaned up!"
