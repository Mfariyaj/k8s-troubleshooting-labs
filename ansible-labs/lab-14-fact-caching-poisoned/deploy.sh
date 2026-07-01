#!/bin/bash
# Lab 14: Fact Caching Poisoned
# Deploy the broken lab environment

set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="/tmp/ansible-lab14"

echo "============================================"
echo "  Lab 14: Fact Caching Poisoned"
echo "============================================"
echo ""
echo "Scenario: Ansible fact caching with Redis returns wrong facts."
echo "Host web-01 receives facts that belong to db-01. Deployments"
echo "are being configured for the WRONG host characteristics."
echo ""
echo "Setting up lab environment..."

mkdir -p "$WORK_DIR/deploy"

# Setup Redis with poisoned cache
echo "Setting up Redis with poisoned fact cache..."
cd "$LAB_DIR"
bash redis-setup.sh 2>&1 || {
    echo ""
    echo "⚠️  Redis setup failed. For this lab, you can also simulate"
    echo "    the issue by examining the ansible.cfg configuration and"
    echo "    understanding why the fact cache would get poisoned."
    echo ""
}

echo ""
echo "Running playbook that relies on cached facts..."
echo "---"

cd "$LAB_DIR"
ansible-playbook playbook.yml -v 2>&1 || true

echo ""
echo "---"
echo ""
echo "⚠️  PROBLEM: Fact cache poisoning detected!"
echo "  - Hosts are receiving facts from OTHER hosts"
echo "  - Stale facts from 24 hours ago are being used"
echo "  - The Redis key namespace has no proper isolation"
echo ""
echo "Your task: Fix the fact caching configuration to prevent"
echo "cross-host fact contamination and stale data."
echo ""
echo "============================================"
