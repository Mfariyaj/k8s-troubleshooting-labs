## Solution: Become Privilege Escalation Failure

### Root Cause

The playbook fails to escalate privileges because:
1. `become: yes` is missing from tasks requiring root access
2. The `become_method` is set incorrectly (not `sudo`)
3. The remote user lacks NOPASSWD sudo configuration, causing password prompts to hang

### Step-by-Step Fix

1. **Add `become: yes` to the play:**
```yaml
- name: Configure web server
  hosts: webservers
  become: yes
  become_method: sudo
```

2. **Fix become_method to sudo:**
```yaml
become_method: sudo
```

3. **Configure NOPASSWD on the target host:**
```bash
# On target host, run visudo and add:
deploy ALL=(ALL) NOPASSWD: ALL
```

### Fixed Configuration

**playbook.yml:**
```yaml
---
- name: Configure web server
  hosts: webservers
  become: yes
  become_method: sudo
  become_user: root
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
```

### Verification

```bash
# Test with verbose output
ansible-playbook playbook.yml -v

# Or provide password interactively if NOPASSWD not configured:
ansible-playbook playbook.yml --ask-become-pass

# Verify privilege escalation works
ansible all -m command -a "whoami" --become
# Should return: root
```

### Key Takeaway

Always specify `become: yes` and `become_method: sudo` for tasks needing root.
For automation, configure NOPASSWD in sudoers for the Ansible user.
