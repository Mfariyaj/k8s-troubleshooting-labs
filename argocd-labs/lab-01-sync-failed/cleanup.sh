#!/bin/bash
echo "🧹 Cleaning up Lab 01: Sync Failed"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete namespace sync-failed-lab --ignore-not-found
echo "✅ Cleanup complete"
