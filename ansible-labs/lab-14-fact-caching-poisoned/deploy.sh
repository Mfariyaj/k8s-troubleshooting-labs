#!/bin/bash
# =============================================================
# Lab 14: Fact Caching Poisoned
# =============================================================
# This lab demonstrates fact cache problems:
#   - Redis fact cache returning wrong host's facts
#   - Stale facts from 24 hours ago being used
#   - No proper key namespace isolation
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 14: Fact Caching Poisoned" \
    "Fact cache returns facts from WRONG hosts causing misconfiguration"

WORK_DIR="/tmp/ansible-lab14"
mkdir -p "$WORK_DIR/deploy"

echo "Running playbook that relies on cached facts..."
echo "---"
ansible-playbook playbook.yml -v 2>&1 || true
echo "---"

echo ""
echo "⚠️  PROBLEM: Fact cache poisoning detected!"
echo "  - Hosts receive facts from OTHER hosts"
echo "  - Stale facts from 24 hours ago being used"
echo "  - Redis key namespace has no proper isolation"
echo ""
echo "Your task: Fix fact caching configuration in ansible.cfg"
echo ""

print_lab_footer
