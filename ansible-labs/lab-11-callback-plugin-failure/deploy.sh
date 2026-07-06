#!/bin/bash
# =============================================================
# Lab 11: Custom Callback Plugin Failure
# =============================================================
# This lab has INTENTIONAL callback plugin problems:
#   - Plugin class name doesn't match filename
#   - CALLBACK_VERSION not set
#   - Plugin path not configured in ansible.cfg
#   - Method signatures wrong
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 11: Custom Callback Plugin Failure" \
    "Custom callback plugin should log events but fires nothing"

echo "Running playbook with custom callback plugin..."
echo "---"
ansible-playbook playbook.yml -v 2>&1 || true
echo "---"

echo ""
echo "⚠️  PROBLEM: The playbook ran but the custom_logger callback"
echo "    plugin did NOT fire any events to the logging system."
echo ""
echo "Expected: v2_playbook_on_start, v2_runner_on_ok events sent"
echo "Actual:   No callback events fired, no errors shown"
echo ""
echo "Your task: Fix ALL issues in the callback plugin."
echo ""

print_lab_footer
