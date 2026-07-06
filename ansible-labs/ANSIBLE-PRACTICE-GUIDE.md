# 🎯 Ansible Practice Labs - Complete Setup & Usage Guide

## Overview

This directory contains **15 hands-on Ansible troubleshooting labs** that run entirely on your local machine using Docker containers as SSH targets. No cloud infrastructure or remote servers needed!

---

## 📋 Prerequisites

| Requirement | Minimum Version | Check Command |
|-------------|----------------|---------------|
| Docker | 20.10+ | `docker --version` |
| Docker Compose | 2.0+ | `docker compose version` |
| Ansible | 2.12+ | `ansible --version` |
| Python | 3.8+ | `python3 --version` |
| sshpass | any | `sshpass -V` |

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Run the Setup Script

```bash
cd ansible-labs/
bash setup-ansible-env.sh
```

This will:
- ✅ Install Ansible (if missing)
- ✅ Check Docker is running
- ✅ Generate SSH keys for lab use
- ✅ Build and start 3 SSH-enabled Docker containers
- ✅ Distribute SSH keys to all containers
- ✅ Create inventory files
- ✅ Create ansible.cfg
- ✅ Test connectivity

### Step 2: Verify Everything Works

```bash
# Test all nodes respond
ansible all -m ping

# Expected output:
# node1 | SUCCESS => {"ping": "pong"}
# node2 | SUCCESS => {"ping": "pong"}
# node3 | SUCCESS => {"ping": "pong"}

# Run a command on all nodes
ansible all -m shell -a "hostname && uptime"
```

### Step 3: Start Your First Lab

```bash
cd lab-01-ssh-connection-failure/
cat README.md          # Read the scenario
./deploy.sh            # Deploy the broken environment
# ... diagnose and fix ...
cat solution.md        # If you're stuck
```

---

## 🖥️ Environment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  YOUR MACHINE (Ansible Control Node)                         │
│                                                             │
│  ansible-playbook → SSH → Docker Containers                 │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  node1      │  │  node2      │  │  node3      │        │
│  │  (web)      │  │  (app)      │  │  (db)       │        │
│  │  port 2201  │  │  port 2202  │  │  port 2203  │        │
│  │  172.20.0.11│  │  172.20.0.12│  │  172.20.0.13│        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  Network: 172.20.0.0/24 (ansible-net)                       │
└─────────────────────────────────────────────────────────────┘
```

### Container Details

| Container | Hostname | SSH Port | IP Address | Role |
|-----------|----------|----------|------------|------|
| ansible-node1 | node1 | 2201 | 172.20.0.11 | Web Server |
| ansible-node2 | node2 | 2202 | 172.20.0.12 | App Server |
| ansible-node3 | node3 | 2203 | 172.20.0.13 | DB Server |

### Users Available on Containers

| User | Password | Sudo | SSH Key |
|------|----------|------|---------|
| ansible | ansible123 | Yes (NOPASSWD) | ✅ |
| deployer | deployer123 | Yes (NOPASSWD) | ✅ |
| root | root123 | N/A | ❌ |

### Installed Software on Containers

- Ubuntu 22.04
- Python3 + python3-apt
- OpenSSH Server
- nginx
- curl, wget, vim
- net-tools, iproute2, iputils-ping
- cron, sudo

---

## 📚 Lab Index

### Beginner Labs (⭐ Easy)

| # | Lab | What You'll Learn |
|---|-----|-------------------|
| 01 | SSH Connection Failure | SSH key permissions, port config, host_key_checking |
| 02 | Become Privilege Escalation | sudo, become_method, become_user |
| 03 | Variable Precedence | group_vars vs host_vars vs role defaults |
| 04 | Handlers Not Triggered | notify naming, flush_handlers, handler ordering |
| 05 | Jinja2 Template Errors | Template syntax, filters, undefined variables |

### Intermediate Labs (⭐⭐ Medium)

| # | Lab | What You'll Learn |
|---|-----|-------------------|
| 06 | Vault Decryption | Vault passwords, vault IDs, encrypted vars |
| 07 | Role Dependencies | Circular deps, meta/main.yml, role paths |
| 08 | Async Task Polling | async/poll values, async_status, fire-and-forget |
| 09 | Delegate To Wrong Host | delegate_to, delegate_facts, run_once |
| 10 | Dynamic Inventory | Custom inventory scripts, JSON format |

### Advanced Labs (⭐⭐⭐ Hard)

| # | Lab | What You'll Learn |
|---|-----|-------------------|
| 11 | Callback Plugin Failure | Plugin class names, CALLBACK_VERSION, paths |
| 12 | Custom Module Broken | Module JSON output, idempotency, check mode |
| 13 | Strategy Plugin Deadlock | free vs linear strategy, serial, race conditions |
| 14 | Fact Caching Poisoned | Redis fact cache, key isolation, TTL |
| 15 | Collection Dependency Hell | Galaxy requirements, collection paths, versions |

---

## 🔧 How to Use Each Lab

### General Workflow

```bash
# 1. Go to lab directory
cd lab-XX-name/

# 2. Read the scenario (understand what's broken)
cat README.md

# 3. Deploy the broken environment
./deploy.sh

# 4. Investigate the error
# Look at: playbook.yml, inventory.ini, ansible.cfg, roles/, templates/
cat playbook.yml
cat inventory.ini
ansible-config dump | grep <setting>

# 5. Fix the issue(s)
vim playbook.yml  # or whatever needs fixing

# 6. Re-run to verify your fix
ansible-playbook -i inventory.ini playbook.yml

# 7. Check solution if stuck
cat solution.md

# 8. Clean up (optional)
./cleanup.sh
```

### Useful Debugging Commands

```bash
# Verbose output (more v's = more detail)
ansible-playbook -i inventory.ini playbook.yml -v
ansible-playbook -i inventory.ini playbook.yml -vvv

# Check syntax without running
ansible-playbook playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook -i inventory.ini playbook.yml --check

# List tasks without running
ansible-playbook playbook.yml --list-tasks

# List hosts in inventory
ansible-inventory -i inventory.ini --list
ansible-inventory -i inventory.ini --graph

# Test connectivity
ansible all -i inventory.ini -m ping
ansible all -i inventory.ini -m ping -vvv

# Run ad-hoc command
ansible all -i inventory.ini -m shell -a "whoami"
ansible all -i inventory.ini -m setup  # Gather facts

# Check ansible config
ansible-config dump
ansible-config dump --only-changed

# Check module documentation
ansible-doc <module_name>
ansible-doc -l | grep <keyword>
```

---

## 🔄 Managing the Environment

### Start / Stop Containers

```bash
# Start containers (from ansible-labs/ directory)
docker-compose up -d

# Stop containers (keeps data)
docker-compose stop

# Stop and remove containers
docker-compose down

# Rebuild after Dockerfile changes
docker-compose build --no-cache
docker-compose up -d
```

### Reset a Container

```bash
# Reset a specific node to clean state
docker-compose restart node1

# Completely rebuild
docker-compose down
docker-compose up -d --build
bash setup-ansible-env.sh  # Re-distribute SSH keys
```

### Check Container Status

```bash
# See running containers
docker-compose ps

# Check logs
docker logs ansible-node1

# Shell into a container
docker exec -it ansible-node1 bash

# Test SSH manually
ssh -i ansible_lab_key -p 2201 -o StrictHostKeyChecking=no ansible@localhost
```

---

## 🎓 Learning Path (Recommended Order)

### Week 1: Ansible Basics
1. **Lab 01** - SSH Connection Failure (understand how Ansible connects)
2. **Lab 02** - Privilege Escalation (understand become/sudo)
3. **Lab 04** - Handlers (understand notify/handler pattern)
4. **Lab 05** - Templates (understand Jinja2 in Ansible)

### Week 2: Configuration Management
5. **Lab 03** - Variable Precedence (master the 22 levels!)
6. **Lab 06** - Vault (secrets management)
7. **Lab 07** - Roles (structuring playbooks)
8. **Lab 08** - Async Tasks (long-running operations)

### Week 3: Advanced Patterns
9. **Lab 09** - Delegation (multi-tier deployments)
10. **Lab 10** - Dynamic Inventory (cloud inventory)
11. **Lab 11** - Callback Plugins (extending Ansible)
12. **Lab 12** - Custom Modules (writing your own)

### Week 4: Expert Topics
13. **Lab 13** - Strategy Plugins (parallel execution)
14. **Lab 14** - Fact Caching (performance at scale)
15. **Lab 15** - Collections (dependency management)

---

## ❓ Troubleshooting

### "Docker containers not running"
```bash
cd ansible-labs/
docker-compose up -d
docker-compose ps  # Should show 3 containers "Up"
```

### "SSH connection refused"
```bash
# Wait 5 seconds for SSH to start
sleep 5
ssh -i ansible_lab_key -p 2201 -o StrictHostKeyChecking=no ansible@localhost

# If still failing, restart containers
docker-compose restart
```

### "Permission denied (publickey)"
```bash
# Re-distribute SSH keys
bash setup-ansible-env.sh
# Or manually:
sshpass -p "ansible123" ssh-copy-id -i ansible_lab_key.pub -p 2201 -o StrictHostKeyChecking=no ansible@localhost
```

### "Ansible not found"
```bash
pip3 install ansible
# or
sudo apt install ansible
```

### "sshpass not found"
```bash
sudo apt install sshpass
# or
sudo yum install sshpass
```

### Resetting Everything from Scratch
```bash
cd ansible-labs/
docker-compose down -v
rm -f ansible_lab_key ansible_lab_key.pub
rm -rf inventory/
bash setup-ansible-env.sh
```

---

## 📖 Key Ansible Concepts Covered

- **Inventory Management**: Static INI, dynamic scripts, groups, host/group vars
- **Connection**: SSH config, keys, passwords, become/sudo
- **Variables**: Precedence (22 levels), group_vars, host_vars, facts
- **Templates**: Jinja2 syntax, filters, loops, conditionals
- **Handlers**: Notify/handler pattern, flush_handlers, listen
- **Roles**: Structure, dependencies, defaults vs vars
- **Vault**: Encryption, vault IDs, password files
- **Async**: Fire-and-forget, polling, async_status
- **Delegation**: delegate_to, delegate_facts, run_once
- **Plugins**: Callbacks, modules, strategies, inventory
- **Collections**: Galaxy, requirements.yml, paths, versions

---

## 📝 Notes

- All labs are **intentionally broken** - that's the point!
- Each lab has a `solution.md` with the fix - try without it first
- Labs are independent - you can do them in any order
- The Docker containers persist between labs (no rebuild needed)
- If you break a container badly, just `docker-compose restart nodeX`

---

*Copyright © 2024-2025 Mfariyaj - DevOps Hands-On Labs*
