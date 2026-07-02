## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 14: Fact Caching Poisoned ⭐⭐⭐⭐⭐

## Difficulty: Expert

## Scenario

Your organization uses Redis-backed Ansible fact caching to speed up playbook runs across a large fleet. After a routine change to the caching configuration, hosts started receiving **wrong facts** — web-01 thinks it's db-01, deployments are configured for the wrong OS, and memory/CPU values don't match reality.

**Root cause investigation reveals multiple configuration errors:**
- The fact caching prefix is empty, causing all hosts to share the same Redis key namespace
- TTL is set to 24 hours, so stale facts persist long after the environment changes
- `gathering = smart` skips fact collection when cache exists (even if poisoned)
- The Redis connection string format may not properly isolate databases
- No mechanism to force-refresh the cache when hosts change

This is a **critical production issue** — hosts are being deployed with configurations based on OTHER hosts' hardware specifications.

## What You'll Observe

```
$ ansible-playbook playbook.yml -v

PLAY [Gather and validate host facts] ******************************************

TASK [Gathering Facts] **********************************************************
ok: [web-01]  # <-- Using cached (WRONG) facts from Redis
ok: [web-02]
ok: [db-01]
ok: [lb-01]

TASK [Display hostname from facts] **********************************************
ok: [web-01] => {
    "msg": "Host web-01 reports hostname as: db-01"   # WRONG! Should be web-01
}
ok: [web-02] => {
    "msg": "Host web-02 reports hostname as: web-01"  # WRONG! Should be web-02
}

TASK [Validate fact correctness] ************************************************
fatal: [web-01]: FAILED! => {
    "assertion": "ansible_hostname == inventory_hostname.split('.')[0]",
    "changed": false,
    "msg": "FACT CACHE POISONING DETECTED! Host web-01 received facts for 'db-01'..."
}
```

With verbose output you might see:
```
$ ansible-playbook playbook.yml -vvv 2>&1 | grep -i "cache\|fact"

Using fact cache: redis
Loading cached facts for web-01
Cached facts are still valid (TTL: 84200 seconds remaining)
```

## Environment

- Ansible 2.15+ with `fact_caching = redis`
- Redis server on localhost:6379
- 6 hosts across 3 groups (webservers, dbservers, loadbalancers)
- `gathering = smart` (uses cache when available)

## Files to Investigate

| File | Purpose |
|------|---------|
| `ansible.cfg` | Fact caching configuration (multiple bugs) |
| `playbook.yml` | Playbook that exposes the poisoning |
| `inventory.ini` | Host inventory |
| `redis-setup.sh` | Script that pre-poisons the cache |

## Hints

<details>
<summary>Hint 1</summary>
The `fact_caching_prefix` is set to an empty string. Without a prefix, Ansible stores facts with just the hostname as the Redis key. If any other application (or a previous Ansible version) wrote to the same keys, or if there's a bug in key construction, facts get mixed between hosts. Set a unique prefix like `ansible_facts_` to namespace the keys properly.
</details>

<details>
<summary>Hint 2</summary>
With `gathering = smart` and `fact_caching_timeout = 86400` (24 hours), Ansible will use cached facts for an entire day without re-gathering. Even if you know the cache is wrong, `gather_facts: true` won't help because 'smart' gathering says "cache is valid, skip gathering." You need to either set `gathering = implicit` (always gather), reduce the timeout drastically, or use `gather_facts: true` with `gather_subset: all` and change gathering mode.
</details>

<details>
<summary>Hint 3</summary>
The `fact_caching_connection` format `localhost:6379:0` may not properly select database 0 in all Ansible versions. Check the Ansible Redis cache plugin documentation for the correct connection string format. Additionally, clearing the poisoned cache with `redis-cli FLUSHDB` is necessary before the fix will take effect — otherwise stale data persists until TTL expires.
</details>

## Useful Commands

```bash
# Run playbook and observe wrong facts
ansible-playbook playbook.yml -v

# Check what's in the Redis cache
redis-cli KEYS '*'
redis-cli GET "web-01" | python3 -m json.tool
redis-cli GET "web-02" | python3 -m json.tool

# Check TTL on cached facts
redis-cli TTL "web-01"
redis-cli TTL "web-02"

# Inspect Ansible's caching configuration
ansible-config dump | grep -i "fact_caching\|gathering\|cache"

# Force fact refresh (doesn't work with smart gathering!)
ansible all -m setup --tree /tmp/facts_check

# Check if facts are being gathered or served from cache
ansible-playbook playbook.yml -vvv 2>&1 | grep -i "cached\|gathering\|loading fact"

# Flush the entire Redis cache
redis-cli FLUSHDB

# Check Redis database isolation
redis-cli SELECT 0
redis-cli DBSIZE

# See what Ansible thinks the prefix is
ansible-config dump | grep CACHE_PLUGIN_PREFIX

# Monitor Redis in real-time while running playbook
redis-cli MONITOR &
ansible-playbook playbook.yml -v
kill %1

# Compare cached facts vs actual facts
ansible web-01 -m setup -a "gather_subset=min" | python3 -m json.tool > /tmp/actual_facts.json
redis-cli GET "web-01" | python3 -m json.tool > /tmp/cached_facts.json
diff /tmp/actual_facts.json /tmp/cached_facts.json

# Test with cache disabled
ANSIBLE_CACHE_PLUGIN=memory ansible-playbook playbook.yml -v
```

## What You Need to Fix

1. **Empty fact_caching_prefix** — Set a proper prefix to namespace Redis keys per-host
2. **Excessive TTL (86400s)** — Reduce to appropriate value (300-600s) for dynamic environments
3. **gathering = smart** — Change to force re-gathering or set shorter cache validity
4. **Flush poisoned cache** — Clear the existing bad data from Redis
5. **Connection string format** — Verify proper Redis connection URI format
6. **Inventory cache conflict** — Separate inventory cache from fact cache namespace

## Success Criteria

- [ ] Each host receives its own correct facts (ansible_hostname matches inventory_hostname)
- [ ] Redis keys are properly namespaced with a prefix
- [ ] Fact cache TTL is set to a reasonable value
- [ ] Running the playbook produces correct host-specific configurations
- [ ] The fact validation assertions pass for all hosts
- [ ] Subsequent plays in the same playbook get fresh facts, not stale cache
