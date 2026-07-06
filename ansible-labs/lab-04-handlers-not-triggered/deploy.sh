#!/bin/bash
# =============================================================
# Lab 04: Handlers Not Triggered
# =============================================================
# This lab has INTENTIONAL handler issues:
#   - Handler name mismatch with notify directive
#   - Handler in wrong section (before tasks that notify it)
#   - Missing flush_handlers when needed mid-play
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 04: Handlers Not Triggered" \
    "Config files are updated but services don't restart - handlers never fire"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml 2>&1 || true
echo "---"

echo ""
echo "⚠️  The playbook may succeed but handlers DON'T fire!"
echo "   nginx config was updated but service was NOT restarted."
echo ""

print_lab_footer
