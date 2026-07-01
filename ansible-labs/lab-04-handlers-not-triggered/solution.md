## Solution: Handlers Not Triggered

### Root Cause

Two issues prevent handlers from executing:
1. **Case mismatch** in handler name: the task notifies `restart nginx` but the handler
   is defined as `Restart Nginx` — handler names are case-sensitive
2. **`ignore_errors: yes`** on a failing task masks the notify or prevents changed status

### Step-by-Step Fix

1. **Fix the handler name to match exactly:**
```yaml
# In tasks:
  notify: Restart Nginx

# In handlers:
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

2. **Remove `ignore_errors`** from tasks that should trigger handlers:
```yaml
- name: Update nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx
  # Removed: ignore_errors: yes
```

### Fixed Configuration

**playbook.yml:**
```yaml
tasks:
  - name: Install nginx
    apt:
      name: nginx
      state: present

  - name: Deploy nginx configuration
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart Nginx

handlers:
  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

### Verification

```bash
# Run playbook — handler should fire when config changes
ansible-playbook playbook.yml -v

# Look for in output:
# RUNNING HANDLER [Restart Nginx]

# Force all handlers to run
ansible-playbook playbook.yml --force-handlers
```

### Key Takeaway

Handler names are **case-sensitive** — `Restart Nginx` != `restart nginx`. Always
copy-paste handler names. Avoid `ignore_errors` on tasks that notify handlers.
