# Solution: Lab 05 — Dictionary Errors

## Root Cause

### Bug 1: json.loads() vs json.load()
```python
# BROKEN: json.loads() is for strings, f is a file object
data = json.loads(f)

# FIXED: json.load() for file objects
data = json.load(f)
```

### Bug 2: Missing "tier" label in some pods
```python
# BROKEN: Direct access fails if key doesn't exist
tier = pod["metadata"]["labels"]["tier"]

# FIXED: Use .get() with a default
tier = pod["metadata"]["labels"].get("tier", "unknown")
```

### Bug 3: Variable state structure
```python
# BROKEN: Not all pods are in "running" state
start_time = container_status["state"]["running"]["startedAt"]

# FIXED: Check which state exists
state = container_status["state"]
if "running" in state:
    start_time = state["running"]["startedAt"]
elif "waiting" in state:
    start_time = f"Waiting: {state['waiting'].get('reason', 'unknown')}"
else:
    start_time = "N/A"
```

---

## Verification

```bash
$ python3 broken_script.py
Loading Kubernetes pod data...
Found 2 pods
======================================================================
  Kubernetes Pod Status Report
======================================================================

  ✅ Pod: nginx-deployment-7fb96c846b-abc12
     Namespace: production
     Tier:      frontend
     Image:     nginx:1.21
     Status:    Running
     Restarts:  0
     Started:   2024-01-15T10:00:00Z

  ❌ Pod: api-server-5d4f6c7b8-xyz99
     Namespace: production
     Tier:      unknown
     Image:     myapp/api:v2.3.1
     Status:    CrashLoopBackOff
     Restarts:  5
     Started:   Waiting: CrashLoopBackOff

======================================================================
  Summary: 1/2 pods running
======================================================================
```

---

## Key Takeaways

1. **`json.load(file)` vs `json.loads(string)`** — know the difference
2. **Always use `.get()` for optional keys** — especially in API responses
3. **K8s/cloud API responses have dynamic structures** — don't assume all fields exist
4. **Chain `.get()` for nested access** — `data.get("a", {}).get("b", "default")`
5. **Test with varied data** — your parser needs to handle all possible response shapes
