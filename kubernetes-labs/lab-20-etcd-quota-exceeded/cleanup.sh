#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 20: ETCD Quota Exceeded..."
echo "==============================================="

# Delete the namespace (removes all namespaced resources including the flooded configmaps)
kubectl delete namespace lab-20-etcd --ignore-not-found=true --timeout=120s
echo "✅ Namespace deleted"

echo ""
echo "🧹 Lab 20 cleanup complete!"
echo ""
echo "NOTE: In a real etcd quota exceeded scenario, you may need to:"
echo "  1. etcdctl compact <revision>"
echo "  2. etcdctl defrag"
echo "  3. etcdctl alarm disarm"
echo "  4. Increase etcd quota with --quota-backend-bytes"
