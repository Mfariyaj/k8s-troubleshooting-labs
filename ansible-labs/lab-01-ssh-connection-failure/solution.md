## Solution: SSH Connection Failure

### Root Cause

Three issues prevent Ansible from establishing an SSH connection:
1. The SSH private key file has overly permissive permissions (must be 600)
2. The SSH port is configured incorrectly (not using default port 22)
3. Host key checking causes failures on first connection to new hosts

### Step-by-Step Fix

1. **Fix key file permissions:**
```bash
chmod 600 fake_key.pem
```

2. **Fix the SSH port in inventory.ini:**
```ini
[webservers]
web1 ansible_host=192.168.1.10 ansible_port=22 ansible_ssh_private_key_file=./fake_key.pem
```

3. **Disable host key checking in ansible.cfg:**
```ini
[defaults]
host_key_checking = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```

### Fixed Configuration

**ansible.cfg:**
```ini
[defaults]
inventory = inventory.ini
remote_user = deploy
host_key_checking = False

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```

### Verification

```bash
# Check key permissions
ls -la fake_key.pem
# Should show: -rw------- (600)

# Test connection
ansible all -m ping

# Run playbook
ansible-playbook playbook.yml -v
```

### Key Takeaway

SSH key files must have strict permissions (600 or 400). Always verify the port
matches the target SSH daemon. Use `host_key_checking = False` in non-production
environments to avoid interactive prompts.
