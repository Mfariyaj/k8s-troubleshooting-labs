## Solution: Fact Caching Poisoned

### Root Cause

Fact caching fails or returns stale/wrong data due to:
1. **Missing unique `fact_caching_prefix`** — multiple projects share the same cache
   namespace, causing cross-contamination
2. **Timeout too high** — stale facts persist long after hosts have changed
3. **Wrong Redis connection format** — incorrect URI causes connection failures

### Step-by-Step Fix

1. **Set a unique fact_caching_prefix:**
```ini
[defaults]
fact_caching_prefix = myproject_
```

2. **Reduce cache timeout to a reasonable value:**
```ini
[defaults]
fact_caching_timeout = 3600
# Not: 86400 (24 hours is too long)
```

3. **Fix Redis connection format:**
```ini
[defaults]
fact_caching = redis
fact_caching_connection = localhost:6379:0
# Format: host:port:db
# Not: redis://localhost:6379 (wrong format for this plugin)
```

### Fixed Configuration

**ansible.cfg:**
```ini
[defaults]
gathering = smart
fact_caching = redis
fact_caching_connection = localhost:6379:0
fact_caching_prefix = lab14_
fact_caching_timeout = 3600
```

### Verification

```bash
# Clear existing poisoned cache
redis-cli KEYS "lab14_*" | xargs redis-cli DEL
# Or flush all:
redis-cli FLUSHDB

# Run playbook to repopulate cache
ansible-playbook playbook.yml -v

# Verify facts are cached correctly
redis-cli KEYS "lab14_*"

# Run again — should use cached facts (faster)
ansible-playbook playbook.yml -v
# Look for "Using cached facts" or skipped gathering
```

### Key Takeaway

Always use a unique `fact_caching_prefix` per project. Keep timeouts short enough
to avoid stale data. Use the correct connection format: `host:port:db` for the
Redis fact cache plugin (not a full URI).
