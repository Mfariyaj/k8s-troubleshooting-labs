#!/bin/bash
# =============================================================
# Lab 08: Async Task Polling Issue
# =============================================================
# This lab has INTENTIONAL async/poll problems:
#   - Wrong async timeout values
#   - Poll interval set incorrectly
#   - async_status task checking wrong job ID
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 08: Async Task Polling Issue" \
    "Long-running async tasks timeout or never report completion"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

echo ""
echo "⚠️  Async tasks are timing out or poll is not working correctly!"
echo ""

print_lab_footer
