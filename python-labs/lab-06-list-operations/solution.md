# Solution: Lab 06 — List Operations

## Root Cause

### Bug 1: Modifying list while iterating
```python
# BROKEN: Removes items while iterating — skips items
for server in servers:
    if server["status"] == "decommissioned":
        servers.remove(server)

# FIXED: Use list comprehension (creates new list)
return [s for s in servers if s["status"] != "decommissioned"]
```

### Bug 2: IndexError with range(count)
```python
# BROKEN: Crashes if count > len(sorted_servers)
for i in range(count):
    top_servers.append(sorted_servers[i])

# FIXED: Use slicing (safe — returns what's available)
return sorted_servers[:count]
```

### Bug 3: Overwriting dict value instead of appending
```python
# BROKEN: Each iteration overwrites the list with a single item
groups[env] = [server]

# FIXED: Use setdefault to append to existing list
groups.setdefault(env, []).append(server)
```

---

## Verification

```bash
$ python3 broken_script.py
Processing server inventory...
============================================================
  Server Inventory Report
============================================================

  Active servers: 8

  Environments:
    production: 5 servers
    development: 2 servers
    staging: 1 servers

  Top 3 servers by RAM:
    db-01: 64GB RAM
    api-01: 32GB RAM
    cache-01: 32GB RAM

  Total resources:
    CPU: 44 cores
    RAM: 192 GB

============================================================
```

---

## Key Takeaways

1. **Never modify a list while iterating** — use comprehensions or iterate over a copy
2. **Use slicing for safe sub-lists** — `lst[:n]` never raises IndexError
3. **Use `setdefault()` for grouping** — `dict.setdefault(key, []).append(val)`
4. **List comprehensions are more Pythonic** than manual filter loops
5. **Test with edge cases** — empty lists, requests larger than list size
