## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 15: Collection Dependency Hell ⭐⭐⭐⭐⭐

## Difficulty: Expert

## Scenario

Your team's infrastructure playbook uses modules from multiple Ansible collections: `community.general`, `community.docker`, `ansible.posix`, and `community.crypto`. After a CI/CD pipeline change, the collections installation step produces conflicting versions, and the playbook loads modules from wrong collection versions.

**The situation is compounded by:**
- Two separate `requirements.yml` files with contradictory version constraints
- `collections_paths` configured in wrong order (system paths before project-local)
- `ansible-galaxy install --force` silently overwrites dependencies when resolving conflicts
- `community.crypto` has a transitive dependency on `community.general >=4.0.0` but the root requirements.yml constrains it to `<3.0.0`
- Features used in the playbook require newer versions than what's pinned

This mirrors real-world "dependency hell" that occurs in large Ansible codebases with multiple teams contributing collection requirements.

## What You'll Observe

```
$ ansible-galaxy collection install -r requirements.yml --force -p ./collections

Starting galaxy collection install process
Process install dependency map
ERROR! Failed to resolve the requested dependencies map.
Got the following errors during the dependency resolution:
* community.crypto:>=2.0.0 requires community.general:>=4.0.0 but the requirement is community.general:<3.0.0

$ ansible-playbook playbook.yml -v

PLAY [Infrastructure provisioning with collections] ****************************

TASK [Generate random password for service] ************************************
fatal: [localhost]: FAILED! => {"msg": "The module community.general.random_string was not found in configured module paths"}

-- OR if an older version got installed: --

ERROR! couldn't resolve module/action 'community.general.random_string'. This often indicates a misspelling, missing collection, or incorrect module path.

TASK [Create Docker network] ***************************************************
fatal: [localhost]: FAILED! => {"msg": "missing required arguments: network_mode"}
-- The module signature is different in docker 1.x vs 2.x+ --
```

Or with path issues:
```
$ ansible-playbook playbook.yml -vvv 2>&1 | grep "collection.*path\|Loading"

Using collection community.general from /usr/share/ansible/collections  # WRONG! Should use ./collections
Loading module from /usr/share/ansible/collections/ansible_collections/community/general/plugins/modules/
# ^ This is the OLD system-installed version, not the project-local one
```

## Environment

- Ansible 2.15+ (ansible-core 2.15.x)
- ansible-galaxy CLI
- Multiple Ansible collections required
- Project-local and system-wide collection installations

## Files to Investigate

| File | Purpose |
|------|---------|
| `requirements.yml` | Root collection requirements (conflicting) |
| `collections/requirements.yml` | Secondary requirements (different conflicts) |
| `ansible.cfg` | Configuration with wrong collections_paths order |
| `playbook.yml` | Playbook using modules from multiple collections |

## Hints

<details>
<summary>Hint 1</summary>
The root `requirements.yml` pins `community.general` to `<3.0.0` but `community.crypto >=2.0.0` has a transitive dependency on `community.general >=4.0.0`. These constraints are mathematically impossible to satisfy simultaneously. You need to either remove the community.crypto requirement or raise the community.general version constraint to satisfy both.
</details>

<details>
<summary>Hint 2</summary>
The `collections_paths` in ansible.cfg lists system paths BEFORE `./collections`. Ansible searches in order and uses the FIRST matching collection. If an old version exists at `/usr/share/ansible/collections` or `~/.ansible/collections`, it will be loaded instead of the project-local one. Reverse the path order to prioritize local collections.
</details>

<details>
<summary>Hint 3</summary>
There are TWO requirements files: `./requirements.yml` and `./collections/requirements.yml` with conflicting version constraints. When CI/CD runs `ansible-galaxy collection install -r`, which file gets used depends on the working directory and flags. Consolidate to a single authoritative requirements file and ensure the playbook features match the installed versions.
</details>

## Useful Commands

```bash
# Try to install collections and see the conflict
ansible-galaxy collection install -r requirements.yml -p ./collections -v

# Force install (silently breaks dependencies)
ansible-galaxy collection install -r requirements.yml -p ./collections --force -v

# List currently installed collections and their versions
ansible-galaxy collection list

# List collections in specific path
ansible-galaxy collection list -p ./collections

# Check which collection path ansible actually uses
ansible-config dump | grep COLLECTIONS_PATHS

# Verify what version of a module would be loaded
ansible-doc community.general.random_string 2>&1 | head -5
ansible-doc community.docker.docker_network 2>&1 | head -5

# Check collection dependency tree
ansible-galaxy collection info community.crypto 2>&1 | grep -i depend

# See where ansible finds a specific module
ansible-playbook playbook.yml -vvvv 2>&1 | grep -i "found.*module\|collection.*path\|Loading"

# Check for duplicate collection installations
find / -path "*/ansible_collections/community/general" -type d 2>/dev/null

# Verify collection version in installed path
cat ./collections/ansible_collections/community/general/MANIFEST.json 2>/dev/null | python3 -m json.tool | grep version

# Test with explicit collection path override
ANSIBLE_COLLECTIONS_PATH=./collections ansible-playbook playbook.yml -v

# Check what the second requirements file says
diff requirements.yml collections/requirements.yml

# Simulate dependency resolution
ansible-galaxy collection install -r requirements.yml --dry-run 2>&1 || true

# Install to correct location with verbose output
ansible-galaxy collection install community.general:5.0.0 -p ./collections -vvv
```

## What You Need to Fix

1. **Version constraint conflicts** — Resolve impossible constraint between community.general <3.0.0 and community.crypto's dependency on >=4.0.0
2. **Duplicate requirements files** — Consolidate into single authoritative source with compatible versions
3. **collections_paths order** — Put project-local path FIRST so it takes precedence
4. **Module version compatibility** — Ensure installed versions support the module features used in playbook
5. **Force install side effects** — Using --force masks dependency conflicts; proper resolution needed

## Success Criteria

- [ ] `ansible-galaxy collection install -r requirements.yml` succeeds without errors
- [ ] No conflicting version constraints between direct and transitive dependencies
- [ ] Collections installed in project-local path are used first
- [ ] `community.general.random_string` module is available (requires >=3.2.0)
- [ ] `community.docker.docker_network` module accepts current parameters (requires >=2.0.0)
- [ ] Running the playbook completes without module-not-found errors
- [ ] Only ONE requirements file exists with consistent, compatible constraints
- [ ] `ansible-galaxy collection list` shows correct versions in correct paths
