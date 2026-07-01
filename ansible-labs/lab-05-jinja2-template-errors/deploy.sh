#!/bin/bash
echo "=== Lab 05: Jinja2 Template Errors ==="
echo "Deploying broken Ansible playbook..."
echo ""
ansible-playbook -i inventory.ini playbook.yml
