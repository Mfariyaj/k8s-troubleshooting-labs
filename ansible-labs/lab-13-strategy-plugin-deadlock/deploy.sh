#!/bin/bash
# =============================================================
# Lab 13: Strategy Plugin Deadlock / Race Condition
# =============================================================
# This lab demonstrates race conditions with free strategy:
#   - Multiple hosts modifying shared resources simultaneously
#   - serial vs strategy misconfiguration
#   - run_once not working correctly with free strategy
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 13: Strategy Plugin Deadlock" \
    "Playbook uses 'strategy: free' causing race conditions on shared resources"

WORK_DIR="/tmp/ansible-lab13"
mkdir -p "$WORK_DIR"/{shared,nodes,locks}
echo "0" > "$WORK_DIR/shared/node_count"
echo -e "---\nnodes:" > "$WORK_DIR/shared/cluster-config.yml"

echo "Running playbook with free strategy..."
echo "---"
ansible-playbook playbook.yml -v 2>&1 || true
echo "---"

echo ""
echo "⚠️  Race condition detected!"
echo "  Expected node count: 20"
echo "  Actual node count: $(cat $WORK_DIR/shared/node_count 2>/dev/null || echo 'FILE MISSING')"
echo ""
echo "Your task: Fix the race conditions and strategy issues."
echo ""

print_lab_footer
