# Solution: Lab 13 — Async & Threading

## Root Cause

### Bug 1: Blocking call in async function
```python
# BROKEN: Blocks the entire event loop!
async def check_server_async(server):
    result = simulate_health_check(server)  # time.sleep() blocks event loop
    return result

# FIXED: Run blocking code in a thread via asyncio
async def check_server_async(server):
    result = await asyncio.to_thread(simulate_health_check, server)
    return result
```

### Bug 2: Sequential awaits instead of concurrent
```python
# BROKEN: Each await waits for the previous one to complete
async def check_all_servers_async():
    tasks = []
    for server in SERVERS:
        result = await check_server_async(server)  # One at a time!
        tasks.append(result)
    return tasks

# FIXED: Create tasks and gather them concurrently
async def check_all_servers_async():
    tasks = [check_server_async(server) for server in SERVERS]
    results = await asyncio.gather(*tasks)
    return list(results)
```

### Bug 3: Shared mutable state in threaded code
```python
# BROKEN: Multiple threads append to shared list (race condition)
results = []  # Global mutable state!
def check_server_threaded(server):
    result = simulate_health_check(server)
    results.append(result)  # Race condition!

# FIXED: Collect from futures instead
def check_all_servers_threaded():
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(simulate_health_check, s) for s in SERVERS]
        results = [f.result() for f in futures]
    return results
```

---

## Verification

After fixing, timing should show:
```
⏱️  Method 1: Sequential checks... ~1.5-2.5s
⏱️  Method 2: Threaded checks...   ~0.3-0.5s  ← Concurrent!
⏱️  Method 3: Async checks...      ~0.3-0.5s  ← Also concurrent!
```

---

## Key Takeaways

1. **Never call blocking functions directly in async** — use `asyncio.to_thread()` or `run_in_executor()`
2. **Use `asyncio.gather()`** for concurrent coroutines — not sequential await in a loop
3. **Avoid shared mutable state** — collect from futures/return values instead
4. **asyncio is for I/O concurrency** — it uses one thread but switches between tasks at await points
5. **Threading works for I/O** — the GIL is released during I/O operations
