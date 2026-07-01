#!/bin/bash
# Lab 12: Custom Module Broken
# Deploy the broken lab environment

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/ansible-lab12"

echo "============================================"
echo "  Lab 12: Custom Ansible Module Broken"
echo "============================================"
echo ""
echo "Scenario: A custom Ansible module 'custom_config' manages"
echo "application configuration files. It's returning invalid output,"
echo "failing idempotency, and doesn't support check mode."
echo ""
echo "Setting up lab environment..."

mkdir -p "$WORK_DIR/config"

echo ""
echo "Running playbook with custom module..."
echo "---"

cd "$LAB_DIR"
ansible-playbook playbook.yml -v 2>&1 || true

echo ""
echo "---"
echo ""
echo "⚠️  PROBLEM: The custom_config module is broken in multiple ways:"
echo "  1. JSON parsing errors in module output"
echo "  2. Idempotency is not working (always reports changed)"
echo "  3. Check mode is not supported"
echo "  4. Argument types are incorrect"
echo ""
echo "Your task: Fix the custom module in library/custom_config.py"
echo ""
echo "============================================"
