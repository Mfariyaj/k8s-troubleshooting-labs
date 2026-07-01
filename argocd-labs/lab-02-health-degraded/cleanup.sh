#!/bin/bash
echo "🧹 Cleaning up Lab 02: Health Degraded"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f deployment.yaml --ignore-not-found
kubectl delete -f service.yaml --ignore-not-found
kubectl delete namespace health-degraded-lab --ignore-not-found
echo "✅ Cleanup complete"
