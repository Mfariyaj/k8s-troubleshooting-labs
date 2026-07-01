#!/bin/bash
# Cleanup all troubleshooting labs

echo "🧹 Cleaning up all troubleshooting labs..."
echo ""

for i in $(seq -w 1 15); do
  ns="lab-$i"
  if kubectl get namespace "$ns" &>/dev/null; then
    echo "   Deleting namespace: $ns"
    kubectl delete namespace "$ns" --grace-period=0 --force 2>/dev/null || kubectl delete namespace "$ns"
  fi
done

echo ""
echo "✅ All lab namespaces deleted."
