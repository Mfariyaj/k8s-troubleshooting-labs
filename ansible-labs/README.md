# 🔧 Ansible Troubleshooting Labs

## 10 Real-World Broken Ansible Scenarios

---

## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

## Overview

This collection contains **10 intentionally broken** Ansible configurations. Each lab presents a real-world failure that you must diagnose and fix using the Ansible CLI and your troubleshooting skills.

---

## 🗂️ Lab Index

## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| # | Lab | Difficulty | Key Concept |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

|---|-----|-----------|-------------|
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 01 | [SSH Connection Failure](lab-01-ssh-connection-failure/) | ⭐ Easy | SSH key permissions, wrong port, host_key_checking |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 02 | [Become Privilege Escalation](lab-02-become-privilege/) | ⭐ Easy | Missing become, wrong become_method, ask_pass |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 03 | [Variable Precedence Conflict](lab-03-variable-precedence/) | ⭐⭐ Medium | role vars vs host_vars vs group_vars precedence |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 04 | [Handlers Not Triggered](lab-04-handlers-not-triggered/) | ⭐ Easy | Case-sensitive handler names, notify mismatch |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 05 | [Jinja2 Template Errors](lab-05-jinja2-template-errors/) | ⭐⭐ Medium | Undefined variables, missing endfor, template syntax |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 06 | [Vault Decryption Failure](lab-06-vault-decryption/) | ⭐⭐ Medium | Wrong vault password, encrypted file decryption |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 07 | [Role Circular Dependencies](lab-07-role-dependencies/) | ⭐⭐ Medium | Circular role deps causing recursion errors |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 08 | [Async Task Polling](lab-08-async-task-polling/) | ⭐⭐⭐ Hard | Fire-and-forget async without async_status check |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 09 | [Delegate To Wrong Host](lab-09-delegate-to-wrong-host/) | ⭐⭐⭐ Hard | Undefined variable in delegate_to directive |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| 10 | [Dynamic Inventory Script](lab-10-dynamic-inventory/) | ⭐⭐⭐ Hard | Non-executable script, invalid JSON format |

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd lab-01-ssh-connection-failure
bash deploy.sh
```

### Deploy all labs:
```bash
bash deploy.sh
```

### Clean up all labs:
```bash
bash cleanup.sh
```

---

## 📋 Prerequisites

## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| Tool | Version | Install |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

|------|---------|---------|
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| `ansible` | 2.9+ | `pip install ansible` |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| `ansible-vault` | (bundled) | Included with ansible |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| `python3` | 3.8+ | System package manager |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| SSH access to test hosts | - | Or use `localhost` with `connection: local` |

---

## ⚔️ Rules of Engagement

1. Deploy the lab → investigate using only CLI tools → identify root cause → fix it
2. Don't peek at the README hints until you've tried for at least 5 minutes
3. Time yourself — most labs should be solvable in under 10 minutes
4. Document what broke and how you fixed it

---

## 📊 Progress Tracker

## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| Lab | Status | Time |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

|-----|--------|------|
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 01 - SSH Connection | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 02 - Become Privilege | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 03 - Variable Precedence | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 04 - Handlers Not Triggered | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 05 - Jinja2 Template Errors | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 06 - Vault Decryption | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 07 - Role Dependencies | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 08 - Async Task Polling | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 09 - Delegate To Wrong Host | _ | _ min |
## 🚀 How To Use These Labs



### Prerequisites:

- `ansible` 2.12+ installed (`pip install ansible`)

- For SSH labs: Docker installed (to create target containers)

- Basic YAML knowledge



### Steps:

1. `cd lab-01-ssh-connection-failure && ./deploy.sh`

2. Read the Ansible error output

3. Fix the playbook/inventory/config

4. Re-run to verify: `ansible-playbook playbook.yml -i inventory.ini`

5. Cleanup: `./cleanup.sh`



---

| ☐ Lab 10 - Dynamic Inventory | _ | _ min |

---

## 💡 General Troubleshooting Tips

- **Verbose mode**: Always try `-v`, `-vv`, or `-vvv` for more details
- **Syntax check**: `ansible-playbook playbook.yml --syntax-check`
- **Dry run**: `ansible-playbook playbook.yml --check`
- **List tasks**: `ansible-playbook playbook.yml --list-tasks`
- **Step mode**: `ansible-playbook playbook.yml --step`
- **Debug module**: Add `debug` tasks to print variable values
- **ansible-config**: `ansible-config dump --only-changed` shows non-default settings

---

## 📜 License

MIT License — break things freely, fix them wisely.
