## Solution: Role Circular Dependencies

### Root Cause

Two or more roles have circular dependencies in their `meta/main.yml`:
- Role A depends on Role B, and Role B depends on Role A
- This creates infinite recursion that Ansible detects and fails on, or causes
  roles to be skipped due to deduplication

### Step-by-Step Fix

1. **Identify the circular dependency:**
```bash
cat roles/*/meta/main.yml
```

2. **Remove the circular reference** — only one role should depend on the other:
```yaml
# roles/app/meta/main.yml
dependencies:
  - role: common
  # Removed: - role: webserver
```

3. **Use `include_role` for conditional inclusion instead:**
```yaml
# In roles/webserver/tasks/main.yml
- name: Include app tasks when needed
  include_role:
    name: app
  when: deploy_app | default(false)
```

4. **Or use `allow_duplicates: true`** if a role must run multiple times:
```yaml
# roles/common/meta/main.yml
allow_duplicates: true
```

### Fixed Configuration

**roles/webserver/meta/main.yml:**
```yaml
---
dependencies:
  - role: common
# Removed circular dep on 'app'
```

**roles/app/meta/main.yml:**
```yaml
---
dependencies:
  - role: common
  - role: webserver
```

### Verification

```bash
# Check for dependency issues
ansible-playbook site.yml --list-tasks

# Run the playbook
ansible-playbook site.yml -v

# Verify role execution order in output
ansible-playbook site.yml -v 2>&1 | grep "ROLE"
```

### Key Takeaway

Design role dependencies as a DAG (directed acyclic graph) — never circular.
Extract shared logic into a `common` role. Use `include_role` for runtime
conditional inclusion instead of hard meta dependencies.
