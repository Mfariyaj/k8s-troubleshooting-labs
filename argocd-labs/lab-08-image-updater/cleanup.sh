#!/bin/bash
echo "🧹 Cleaning up Lab 08: Image Updater"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f deployment.yaml --ignore-not-found
kubectl delete namespace image-updater-lab --ignore-not-found
echo "✅ Cleanup complete"
