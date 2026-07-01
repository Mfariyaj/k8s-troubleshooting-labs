## Solution: Delegate To Wrong Host

### Root Cause

Two issues with task delegation:
1. **Undefined `lb_server` variable** — `delegate_to: "{{ lb_server }}"` fails because
   the variable is never defined
2. **Missing `delegate_facts: true`** — facts gathered on delegated host are stored
   against the original host, causing incorrect data

### Step-by-Step Fix

1. **Define the `lb_server` variable in inventory or group_vars:**
```ini
[webservers:vars]
lb_server=lb1
```

2. **Add `delegate_facts: true`:**
```yaml
- name: Get LB status
  command: haproxy -c -f /etc/haproxy/haproxy.cfg
  delegate_to: "{{ lb_server }}"
  delegate_facts: true
```

### Fixed Configuration

**inventory.ini:**
```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[loadbalancers]
lb1 ansible_host=192.168.1.5

[all:vars]
lb_server=lb1
```

**playbook.yml:**
```yaml
---
- name: Rolling update with LB management
  hosts: webservers
  serial: 1
  tasks:
    - name: Disable server in load balancer
      command: disable server backend/{{ inventory_hostname }}
      delegate_to: "{{ lb_server }}"
      delegate_facts: true

    - name: Update application
      apt:
        name: myapp
        state: latest

    - name: Re-enable server in load balancer
      command: enable server backend/{{ inventory_hostname }}
      delegate_to: "{{ lb_server }}"
      delegate_facts: true
```

### Verification

```bash
# Check variable is defined
ansible all -m debug -a "var=lb_server"

# Run the playbook
ansible-playbook playbook.yml -v

# Verify delegation in output:
# "delegated to lb1"
```

### Key Takeaway

Always define variables used in `delegate_to`. Use `delegate_facts: true` when
facts from the delegated host should be stored under that host's name.
