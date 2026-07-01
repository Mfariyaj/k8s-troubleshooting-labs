#!/bin/bash
# Lab 13: Strategy Plugin Deadlock / Race Condition
# Deploy the broken lab environment

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/ansible-lab13"

echo "============================================"
echo "  Lab 13: Strategy Plugin Deadlock"
echo "============================================"
echo ""
echo "Scenario: A playbook deploys configuration across 20 nodes"
echo "using 'strategy: free' for speed. Tasks that modify shared"
echo "resources are racing against each other, causing corruption."
echo ""
echo "Setting up lab environment..."

# Create shared directories
mkdir -p "$WORK_DIR"/{shared,nodes,locks}
echo "0" > "$WORK_DIR/shared/node_count"
touch "$WORK_DIR/shared/cluster-config.yml"
echo "---" > "$WORK_DIR/shared/cluster-config.yml"
echo "nodes:" >> "$WORK_DIR/shared/cluster-config.yml"

echo ""
echo "Running playbook with free strategy across 20 hosts..."
echo "---"

cd "$LAB_DIR"
ansible-playbook playbook.yml -v 2>&1 || true

echo ""
echo "---"
echo ""
echo "⚠️  PROBLEM: Race condition detected!"
echo ""
echo "Checking shared state:"
echo "  Expected node count: 20"
echo "  Actual node count: $(cat $WORK_DIR/shared/node_count 2>/dev/null || echo 'FILE MISSING')"
echo "  Registered nodes: $(grep -c 'active' $WORK_DIR/shared/cluster-config.yml 2>/dev/null || echo 0)"
echo "  Cert requests: $(wc -l < $WORK_DIR/shared/cert-requests.txt 2>/dev/null || echo 0)"
echo ""
echo "Your task: Fix the race conditions and strategy issues."
echo ""
echo "============================================"
