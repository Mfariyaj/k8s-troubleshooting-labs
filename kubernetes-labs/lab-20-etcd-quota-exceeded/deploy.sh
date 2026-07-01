#!/bin/bash
set -e

echo "🚀 Deploying Lab 20: ETCD Quota Exceeded Simulation..."
echo "======================================================="

# Create namespace
kubectl apply -f namespace.yaml
echo "✅ Namespace created"

sleep 2

# Apply the resources
kubectl apply -f broken-deployment.yaml
echo "✅ Resources applied"

echo ""
echo "⏳ Waiting for the configmap-flood job to start creating resources..."
echo "   This simulates a runaway pipeline leaking configmaps into etcd."
echo "   In production, this fills etcd until the quota is exceeded."
echo ""

# Wait for the job to start
kubectl wait --for=condition=ready pod -l app=configmap-flood -n lab-20-etcd --timeout=60s 2>/dev/null || true

echo ""
echo "⏳ ConfigMap generation in progress (this takes 1-2 minutes)..."
echo "   Monitor with: kubectl logs -f job/configmap-flood -n lab-20-etcd"
echo ""

# Wait for the job to complete
kubectl wait --for=condition=complete job/configmap-flood -n lab-20-etcd --timeout=300s 2>/dev/null || true

echo ""
echo "🔥 Lab 20 is now active!"
echo "======================================================="
echo ""
echo "SCENARIO: The cluster API server is returning errors when creating new resources."
echo "In a real scenario, you would see:"
echo "  'etcdserver: mvcc: database space exceeded'"
echo ""
echo "The namespace lab-20-etcd is flooded with leaked ConfigMaps from a CI pipeline."
echo ""
echo "Your task: Identify the source of resource leakage, clean it up,"
echo "and understand how to prevent etcd space exhaustion."
echo ""
echo "Start with:"
echo "  kubectl get configmaps -n lab-20-etcd | wc -l"
echo "  kubectl get configmaps -n lab-20-etcd -l leaked=true --no-headers | wc -l"
echo "  kubectl top configmaps -n lab-20-etcd (resource usage)"
