#!/bin/bash
echo "🧹 Cleaning up Lab 07: Sync Waves"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f manifests/ --ignore-not-found
kubectl delete namespace sync-waves-lab --ignore-not-found
echo "✅ Cleanup complete"
