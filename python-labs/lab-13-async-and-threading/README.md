# Lab 13: Async & Threading — Concurrency in Python

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-13/broken_script.py
cd /tmp/python-lab-13 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Concurrency with asyncio and threading**

Python has several concurrency models:

- **Threading** — good for I/O-bound tasks (network calls, file I/O). Threads share memory but CPython's GIL limits CPU parallelism.
- **asyncio** — cooperative multitasking for I/O. Non-blocking, single-threaded. Must use `await` for I/O operations.
- **multiprocessing** — true parallelism for CPU-bound tasks. Each process has its own GIL.
- **concurrent.futures** — high-level API wrapping threads and processes.

Key mistakes:
- **Calling blocking code in async** — `time.sleep()` in an async function blocks the entire event loop. Use `await asyncio.sleep()`.
- **Sequential `await` in a loop** — `for x: await task(x)` runs one at a time. Use `asyncio.gather()` for concurrency.
- **Shared mutable state** — multiple threads modifying the same list/dict without locks causes race conditions.
- **GIL misconception** — threads don't speed up CPU-bound code, only I/O-bound code.

---

## 🔧 Scenario

A health checker that checks 5 servers concurrently. It compares three methods: sequential, threaded, and async. The async version should be as fast as the threaded version, but due to bugs, it runs sequentially.

---

## 💥 Error Output

The script runs without crashing, but the timing reveals the bug:
```
⏱️  Method 1: Sequential checks... 1.85s
⏱️  Method 2: Threaded checks... 0.45s
⏱️  Method 3: Async checks... 1.80s   ← Should be ~0.45s!
```

The async version is just as slow as sequential because it's not actually concurrent.

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Look at `check_all_servers_async()`. It uses `await` inside a for loop — this means each check waits for the previous one to complete before starting the next. How do you run multiple awaits concurrently?
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `check_server_async()` calls `simulate_health_check()` directly — this is a blocking call that stalls the event loop. Use `asyncio.to_thread()` or `loop.run_in_executor()`.
2. `check_all_servers_async()` awaits each task sequentially in a loop. Use `asyncio.gather()` to run them all concurrently.
3. The shared `results` list in threaded code has a race condition — use a lock or collect results from futures instead.
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. In `check_server_async()`:
   ```python
   result = await asyncio.to_thread(simulate_health_check, server)
   ```
2. In `check_all_servers_async()`:
   ```python
   tasks = [check_server_async(server) for server in SERVERS]
   results = await asyncio.gather(*tasks)
   return list(results)
   ```
3. For thread safety, collect results from `future.result()` instead of using shared list:
   ```python
   results = [future.result() for future in futures]
   ```
</details>

---

## 📖 Python Docs Reference

- [asyncio](https://docs.python.org/3/library/asyncio.html)
- [asyncio.gather()](https://docs.python.org/3/library/asyncio-task.html#asyncio.gather)
- [concurrent.futures](https://docs.python.org/3/library/concurrent.futures.html)
- [threading](https://docs.python.org/3/library/threading.html)
- [GIL](https://docs.python.org/3/glossary.html#term-global-interpreter-lock)

---

## Difficulty: ⭐⭐⭐⭐ Expert

**Expected time:** 10-15 minutes  
**Bugs to find:** 3  
**Concept:** asyncio vs threading, blocking in async, gather vs sequential await
