#!/bin/bash
# Lab 15: Collection Dependency Hell
# Deploy the broken lab environment

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/ansible-lab15"

echo "============================================"
echo "  Lab 15: Collection Dependency Hell"
echo "============================================"
echo ""
echo "Scenario: A playbook uses modules from multiple Ansible"
echo "collections (community.general, community.docker, ansible.posix)"
echo "but version constraints conflict and collections are installed"
echo "in the wrong path order."
echo ""
echo "Setting up lab environment..."

mkdir -p "$WORK_DIR/config"
mkdir -p "$LAB_DIR/collections/ansible_collections"

echo ""
echo "Attempting to install collections from requirements.yml..."
echo "---"

cd "$LAB_DIR"

# Try to install with the conflicting requirements
ansible-galaxy collection install -r requirements.yml --force -p ./collections 2>&1 || true

echo ""
echo "---"
echo ""
echo "Running playbook..."
echo "---"

ansible-playbook playbook.yml -v 2>&1 || true

echo ""
echo "---"
echo ""
echo "⚠️  PROBLEMS detected:"
echo "  1. Collection version conflicts in requirements.yml"
echo "  2. Modules from wrong collection versions being loaded"
echo "  3. Collections installed in wrong path (not searched first)"
echo "  4. Two conflicting requirements files"
echo ""
echo "Your task: Resolve the dependency conflicts and fix the"
echo "collection path configuration."
echo ""
echo "============================================"
