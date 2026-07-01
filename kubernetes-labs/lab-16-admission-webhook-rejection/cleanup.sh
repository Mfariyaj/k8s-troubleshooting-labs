#!/bin/bash
set -e

echo "🧹 Cleaning up Lab 16: Admission Webhook Rejection..."
echo "=================================================="

# Delete the validating webhook configuration (cluster-scoped)
kubectl delete validatingwebhookconfiguration pod-security-validator.lab-16-webhook.svc --ignore-not-found=true
echo "✅ ValidatingWebhookConfiguration deleted"

# Delete the namespace (removes all namespaced resources)
kubectl delete namespace lab-16-webhook --ignore-not-found=true
echo "✅ Namespace deleted"

echo ""
echo "🧹 Lab 16 cleanup complete!"
