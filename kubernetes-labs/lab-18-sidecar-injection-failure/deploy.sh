#!/bin/bash
set -e

echo "🚀 Deploying Lab 18: Sidecar Injection Failure..."
echo "=================================================="

# Create namespace
kubectl apply -f namespace.yaml
echo "✅ Namespace created"

sleep 2

# Apply broken deployment and config
kubectl apply -f broken-deployment.yaml
echo "✅ Resources applied"

echo ""
echo "⏳ Waiting for pods to attempt starting..."
sleep 15

echo ""
echo "🔥 Lab 18 is now active!"
echo "=================================================="
echo "SCENARIO: Istio sidecar injection is failing for the notification service."
echo "Init containers are crashing, blocking main container startup."
echo ""
echo "Your task: Diagnose why sidecar injection is failing and fix all issues."
echo ""
echo "Start with:"
echo "  kubectl get pods -n lab-18-sidecar"
echo "  kubectl describe pod -l app=notification-svc -n lab-18-sidecar"
echo "  kubectl logs -l app=notification-svc -c istio-init -n lab-18-sidecar"
