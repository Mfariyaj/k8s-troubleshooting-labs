#!/bin/bash
set -e

echo "🚀 Deploying Lab 19: CRD Validation Failure..."
echo "================================================"

# Create namespace
kubectl apply -f namespace.yaml
echo "✅ Namespace created"

sleep 2

# Apply broken deployment — expect errors
echo ""
echo "Applying CRD and Custom Resources..."
echo "======================================"
kubectl apply -f broken-deployment.yaml 2>&1 || true

echo ""
echo "🔥 Lab 19 is now active!"
echo "================================================"
echo "SCENARIO: DatabaseCluster CRD has schema validation issues."
echo "Custom Resources are failing to create with cryptic errors."
echo ""
echo "Your task: Fix the CRD schema and CR instances so they pass validation."
echo ""
echo "Start with:"
echo "  kubectl get crd databaseclusters.platform.example.com"
echo "  kubectl apply -f broken-deployment.yaml --dry-run=server 2>&1"
echo "  kubectl get crd databaseclusters.platform.example.com -o yaml"
