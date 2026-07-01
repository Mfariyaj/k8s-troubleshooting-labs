#!/bin/bash
set -e

echo "============================================"
echo "Lab 14: Release History Overflow"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "This lab simulates a release with excessive history."
echo "It will create 55+ revisions to overflow etcd storage."
echo ""
echo "Step 1: Running simulation script..."
echo ""

./simulate-releases.sh

echo ""
echo "Step 2: Attempting upgrade (this should fail or be very slow)..."
echo ""
echo "Running: helm upgrade history-overflow ./mychart --namespace lab14-history --set config.version=v56"
helm upgrade history-overflow ./mychart \
  --namespace lab14-history \
  --set config.version=v56

echo ""
echo "Step 3: Attempting rollback to corrupted revision..."
echo ""
echo "Running: helm rollback history-overflow 25 --namespace lab14-history"
helm rollback history-overflow 25 --namespace lab14-history

echo ""
echo "If you see errors, your task is to fix the release history overflow!"
