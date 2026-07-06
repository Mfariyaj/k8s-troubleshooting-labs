#!/bin/bash
# =============================================================
# Lab 06: Vault Decryption Failure
# =============================================================
# This lab has INTENTIONAL vault problems:
#   - Wrong vault password file referenced
#   - Multiple vault IDs conflicting
#   - Vault-encrypted file with wrong password
# =============================================================

source "$(dirname "$0")/../lab-helper.sh"
check_environment

print_lab_header "Lab 06: Vault Decryption Failure" \
    "Ansible cannot decrypt vault-encrypted secrets - wrong password file"

echo "Running broken playbook..."
echo "---"
ansible-playbook -i inventory.ini playbook.yml --vault-password-file vault-password.txt 2>&1 || true
echo "---"

echo ""
echo "⚠️  Vault decryption failed! Check which password file is correct."
echo "   Files available: vault-password.txt, vault_pass.txt, .vault_pass"
echo ""

print_lab_footer
