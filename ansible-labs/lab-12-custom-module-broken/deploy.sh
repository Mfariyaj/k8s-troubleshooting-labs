#!/bin/bash
# =============================================================
# Lab 12: Custom Ansible Module Broken
# =============================================================
# This lab has INTENTIONAL module problems:
#   - JSON parsing errors in module output
#   - Idempotency not working (always reports changed)
#   - Check mode not supported
#   - Argument types incorrect
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 12: Custom Ansible Module Broken" \
    "Custom module 'custom_config' produces invalid output and breaks idempotency"

echo "Running playbook with custom module..."
echo "---"
ansible-playbook playbook.yml -v 2>&1 || true
echo "---"

echo ""
echo "⚠️  PROBLEMS in library/custom_config.py:"
echo "  1. JSON parsing errors in module output"
echo "  2. Always reports 'changed' (not idempotent)"
echo "  3. Check mode not supported"
echo "  4. Argument types incorrect"
echo ""
echo "Your task: Fix the custom module"
echo ""

print_lab_footer
