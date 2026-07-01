#!/bin/bash
# This script simulates a release with excessive history
# It creates many Helm release secrets to simulate the overflow condition

set -e

NAMESPACE="lab14-history"
RELEASE_NAME="history-overflow"

echo "============================================"
echo "Simulating Release History Overflow"
echo "============================================"
echo ""

# Create namespace
kubectl create namespace $NAMESPACE 2>/dev/null || true

echo "Creating initial release..."
helm install $RELEASE_NAME ./mychart \
  --namespace $NAMESPACE \
  --set config.version=v1

echo ""
echo "Simulating 55 upgrades (creating excessive release history)..."
echo "This simulates a CI/CD pipeline that deploys on every commit without --history-max"
echo ""

for i in $(seq 2 55); do
  echo "  Upgrade #$i..."
  helm upgrade $RELEASE_NAME ./mychart \
    --namespace $NAMESPACE \
    --set config.version="v${i}" \
    --set config.timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>/dev/null || true
done

echo ""
echo "Creating a corrupted release secret (simulating etcd corruption)..."
# Create a fake release secret with wrong labels to simulate corruption
kubectl create secret generic "sh.helm.release.v1.${RELEASE_NAME}.v25" \
  --namespace $NAMESPACE \
  --from-literal=release="corrupted-data-not-valid-base64-gzipped-protobuf" \
  2>/dev/null || true

# Relabel it incorrectly to simulate label mismatch
kubectl label secret "sh.helm.release.v1.${RELEASE_NAME}.v25" \
  --namespace $NAMESPACE \
  --overwrite \
  owner=helm \
  status=superseded \
  name=$RELEASE_NAME \
  version="25" \
  modifiedAt="corrupted" 2>/dev/null || true

echo ""
echo "============================================"
echo "Simulation complete!"
echo ""
echo "Current state:"
echo "  - Release '$RELEASE_NAME' has 55+ revisions stored as K8s secrets"
echo "  - Revision 25 has corrupted data"
echo "  - No --history-max was ever set"
echo "  - etcd is approaching storage limits"
echo ""
echo "Now try:"
echo "  helm upgrade $RELEASE_NAME ./mychart --namespace $NAMESPACE --set config.version=v56"
echo "  helm rollback $RELEASE_NAME 25 --namespace $NAMESPACE"
echo "============================================"
