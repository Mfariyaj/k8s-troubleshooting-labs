#!/bin/bash
set -e

echo "🚀 Deploying Lab 17: Pod Disruption Budget Blocking Drain..."
echo "============================================================"

# Create namespace
kubectl apply -f namespace.yaml
echo "✅ Namespace created"

sleep 2

# Apply deployments and PDBs
kubectl apply -f broken-deployment.yaml
echo "✅ Resources applied"

echo ""
echo "⏳ Waiting for pods to become ready..."
kubectl wait --for=condition=available deployment/order-processor -n lab-17-pdb --timeout=120s 2>/dev/null || true
kubectl wait --for=condition=available deployment/inventory-service -n lab-17-pdb --timeout=120s 2>/dev/null || true

sleep 5

echo ""
echo "🔥 Lab 17 is now active!"
echo "============================================================"
echo "SCENARIO: Cluster upgrade is stuck. Node drain is failing."
echo "PodDisruptionBudget is blocking all evictions."
echo ""
echo "Your task: Diagnose why node drain is blocked and fix it."
echo ""
echo "Simulate the problem:"
echo "  kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data"
echo ""
echo "Start investigating with:"
echo "  kubectl get pdb -n lab-17-pdb"
echo "  kubectl describe pdb -n lab-17-pdb"
echo "  kubectl get pods -n lab-17-pdb -o wide"
