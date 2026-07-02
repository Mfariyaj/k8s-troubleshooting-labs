# Lab 08: Exception Handling — try/except/finally & Custom Exceptions

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-08/broken_script.py
cd /tmp/python-lab-08 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Exception Handling Best Practices**

Python's exception handling is powerful but easy to misuse. Common anti-patterns:

- **Bare `except:`** — catches EVERYTHING including `KeyboardInterrupt`, `SystemExit`, memory errors. Always specify the exception type.
- **Wrong exception type** — catching `TypeError` when `ValueError` is raised means the error slips through unhandled.
- **Swallowed exceptions** — catching an error but doing nothing with it (no logging, no re-raising). You lose all diagnostic information.
- **Missing `finally`** — cleanup code that should always run (close connections, log attempts) gets skipped when exceptions occur.

Best practices:
- Catch the most specific exception type possible
- Always log or report the error: `except SomeError as e: logger.error(f"Failed: {e}")`
- Use `finally:` for cleanup that must always happen
- Create custom exception classes for domain-specific errors
- Use `raise` to re-raise if you can't fully handle it

---

## 🔧 Scenario

A service health check client that queries multiple internal service endpoints. It needs to handle connection timeouts, HTTP errors, and invalid response bodies — then produce a clear status report showing which services are healthy and which failed.

---

## 💥 Error Output

The script runs without crashing, but produces incorrect results:
- Services that should show specific errors show "unknown" status
- The retry function crashes because it has no error handling
- Some genuine API errors are silently swallowed

```
🔍 Checking service health...

Traceback (most recent call last):
  File "broken_script.py", line 131, in <module>
    main()
  File "broken_script.py", line 127, in main
    final_results = retry_failed_checks(results, services)
  File "broken_script.py", line 93, in retry_failed_checks
    response = check_endpoint(name, url)
  ...
ConnectionError: Connection to http://cache-redis.internal/health timed out after 5s
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

The script has three types of exception handling problems: wrong exception type, too-broad catch, and missing try/except entirely. Look at each `try/except` block and ask "what exception can actually be raised here?"
</details>

<details>
<summary>Hint 2 (More specific)</summary>

1. In `parse_health_response()`: `json.loads()` of an invalid string raises `json.JSONDecodeError` (a subclass of `ValueError`), NOT `TypeError`
2. In `check_all_services()`: The bare `except:` catches everything but records "unknown" — it should catch specific exceptions and record what actually went wrong
3. In `retry_failed_checks()`: There's no try/except at all — a ConnectionError on retry crashes everything
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Change `except TypeError:` to `except (json.JSONDecodeError, ValueError):`
2. Change `except:` to `except (ConnectionError, ServiceCheckError) as e:` and include the error: `{"service": name, "status": "unhealthy", "details": {"error": str(e)}}`
3. Wrap the retry loop body in `try/except (ConnectionError, ServiceCheckError): continue` with a `finally` block or error handling after the for loop
</details>

---

## 📖 Python Docs Reference

- [Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)
- [Built-in Exceptions](https://docs.python.org/3/library/exceptions.html)
- [Exception Hierarchy](https://docs.python.org/3/library/exceptions.html#exception-hierarchy)
- [Custom Exceptions](https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions)

---

## Difficulty: ⭐⭐ Intermediate

**Expected time:** 7-10 minutes  
**Bugs to find:** 3  
**Concept:** Exception types, handling patterns, and debugging silent failures
