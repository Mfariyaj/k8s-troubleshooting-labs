## Solution: Collection Dependency Hell

### Root Cause

Collection installation and usage fails due to:
1. **Incompatible version constraints** — requirements.yml specifies versions that
   conflict with each other's dependencies
2. **Wrong `collections_paths` order** — Ansible looks in the wrong directory first,
   finding old or missing versions
3. **Cached old versions** — previously installed collections conflict with new ones

### Step-by-Step Fix

1. **Fix version constraints in requirements.yml:**
```yaml
---
collections:
  - name: community.general
    version: ">=5.0.0,<7.0.0"
  - name: ansible.posix
    version: ">=1.4.0"
  - name: community.crypto
    version: ">=2.0.0"
```

2. **Fix collections_paths order in ansible.cfg:**
```ini
[defaults]
collections_paths = ./collections:~/.ansible/collections:/usr/share/ansible/collections
```
The project-local path must come first.

3. **Force reinstall with dependency resolution:**
```bash
ansible-galaxy collection install -r requirements.yml \
  --force-with-deps -p ./collections
```

### Fixed Configuration

**ansible.cfg:**
```ini
[defaults]
collections_paths = ./collections:~/.ansible/collections:/usr/share/ansible/collections
```

**requirements.yml:**
```yaml
---
collections:
  - name: community.general
    version: ">=5.0.0"
  - name: ansible.posix
    version: ">=1.4.0"
  - name: community.crypto
    version: ">=2.0.0"
```

### Verification

```bash
# Remove old collections
rm -rf ./collections/ansible_collections

# Reinstall with forced dependency resolution
ansible-galaxy collection install -r requirements.yml \
  --force-with-deps -p ./collections

# Verify installed versions
ansible-galaxy collection list

# Run the playbook
ansible-playbook playbook.yml -v
```

### Key Takeaway

Use flexible version ranges (not exact pins) unless required. Put project-local
`collections_paths` first. Use `--force-with-deps` to resolve dependency conflicts
when reinstalling collections.
