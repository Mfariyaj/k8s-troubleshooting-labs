## Solution: Strategy Plugin Deadlock

### Root Cause

The playbook deadlocks because:
1. **`serial` used with `strategy: free`** — these are incompatible; `serial` limits
   batch size while `free` tries to run tasks independently, causing conflicts
2. **Shared resources** without throttling — multiple hosts access the same resource
   concurrently causing race conditions
3. **High `forks` value** — too many parallel workers overwhelm the control node

### Step-by-Step Fix

1. **Remove `serial` when using `strategy: free`:**
```yaml
- hosts: webservers
  strategy: free
  # Remove: serial: 2
```

2. **Add `throttle: 1` on tasks accessing shared resources:**
```yaml
- name: Update shared database schema
  command: /opt/migrate.sh
  throttle: 1   # Only one host runs this at a time
```

3. **Reduce forks in ansible.cfg:**
```ini
[defaults]
forks = 5
# Not: forks = 50
```

### Fixed Configuration

**ansible.cfg:**
```ini
[defaults]
forks = 5
strategy = free
```

**playbook.yml:**
```yaml
---
- name: Deploy application
  hosts: webservers
  strategy: free
  tasks:
    - name: Update application code
      copy:
        src: app/
        dest: /opt/app/

    - name: Run database migration (one at a time)
      command: /opt/scripts/migrate.sh
      throttle: 1
      run_once: true

    - name: Restart application
      service:
        name: myapp
        state: restarted
```

### Verification

```bash
# Run the playbook
ansible-playbook playbook.yml -v

# Monitor for deadlocks — should complete without hanging
# Check timing shows parallel execution except throttled tasks

# If still having issues, try linear strategy:
ansible-playbook playbook.yml -v -e "ansible_strategy=linear"
```

### Key Takeaway

Never combine `serial` with `strategy: free`. Use `throttle` on individual tasks
that need serialization. Keep `forks` reasonable for your control node capacity.
