#!/bin/bash
echo "🧹 Cleaning up Lab 04: Repo Connection Failure"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f repo-secret.yaml --ignore-not-found
kubectl delete namespace repo-connection-lab --ignore-not-found
echo "✅ Cleanup complete"
