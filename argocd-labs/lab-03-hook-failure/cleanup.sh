#!/bin/bash
echo "🧹 Cleaning up Lab 03: Hook Failure"
kubectl delete -f application.yaml --ignore-not-found
kubectl delete -f hooks/pre-sync-job.yaml --ignore-not-found
kubectl delete namespace hook-failure-lab --ignore-not-found
echo "✅ Cleanup complete"
