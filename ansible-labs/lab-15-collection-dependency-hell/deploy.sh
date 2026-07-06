#!/bin/bash
# =============================================================
# Lab 15: Collection Dependency Hell
# =============================================================
# This lab demonstrates collection management problems:
#   - Conflicting version requirements in requirements.yml
#   - Collections installed in wrong path order
#   - Module from wrong collection version being loaded
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 15: Collection Dependency Hell" \
    "Conflicting collection versions cause module loading failures"

mkdir -p "./collections/ansible_collections"

echo "Attempting to install collections from requirements.yml..."
echo "---"
ansible-galaxy collection install -r requirements.yml --force -p ./collections 2>&1 || true
echo "---"
echo ""
echo "Running playbook..."
echo "---"
ansible-playbook playbook.yml -v 2>&1 || true
echo "---"

echo ""
echo "⚠️  PROBLEMS:"
echo "  1. Collection version conflicts in requirements.yml"
echo "  2. Modules from wrong collection versions loaded"
echo "  3. Collections installed in wrong path"
echo ""
echo "Your task: Resolve dependency conflicts and fix paths."
echo ""

print_lab_footer
