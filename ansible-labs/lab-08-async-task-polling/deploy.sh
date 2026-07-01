#!/bin/bash
echo "=== Lab 08: Async Task Polling Issue ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
