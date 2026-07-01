#!/bin/bash
# Lab 11: Callback Plugin Failure
# Deploy the broken lab environment

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/ansible-lab11"

echo "============================================"
echo "  Lab 11: Custom Callback Plugin Failure"
echo "============================================"
echo ""
echo "Scenario: A custom callback plugin should send all task"
echo "execution events as JSON to an external logging system."
echo "Tasks appear to run normally, but NO callback events fire."
echo ""
echo "Setting up lab environment..."

# Create working directories
mkdir -p "$WORK_DIR"/{config,logs}

echo ""
echo "Running playbook with custom callback plugin..."
echo "---"

cd "$LAB_DIR"
ansible-playbook playbook.yml -v 2>&1 || true

echo ""
echo "---"
echo ""
echo "⚠️  PROBLEM: The playbook ran but the custom_logger callback"
echo "    plugin did NOT fire any events to the logging system."
echo ""
echo "Expected behavior:"
echo "  - v2_playbook_on_start event sent"
echo "  - v2_runner_on_ok event sent for each task"
echo "  - v2_playbook_on_stats event sent at completion"
echo ""
echo "Actual behavior:"
echo "  - No callback events were sent"
echo "  - No error messages about the callback plugin"
echo "  - Tasks appear to complete normally"
echo ""
echo "Your task: Diagnose why the callback plugin fails silently"
echo "and fix ALL issues preventing it from functioning."
echo ""
echo "============================================"
