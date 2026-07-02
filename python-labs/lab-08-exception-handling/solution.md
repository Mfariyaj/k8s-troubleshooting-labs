# Solution: Lab 08 — Exception Handling

## Root Cause

### Bug 1: Wrong exception type in parse_health_response()
```python
# BROKEN: json.loads raises JSONDecodeError, not TypeError
except TypeError:
    return {"healthy": False, "error": "Invalid response format"}

# FIXED: Catch the right exception
except (json.JSONDecodeError, ValueError):
    return {"healthy": False, "error": "Invalid response format"}
```

### Bug 2: Bare except swallows all errors
```python
# BROKEN: Catches everything, loses error info
except:
    results.append({"service": name, "status": "unknown"})

# FIXED: Catch specific exceptions, preserve error details
except ConnectionError as e:
    results.append({"service": name, "status": "unhealthy", "details": {"error": f"Timeout: {e}"}})
except ServiceCheckError as e:
    results.append({"service": name, "status": "unhealthy", "details": {"error": str(e)}})
except (json.JSONDecodeError, ValueError) as e:
    results.append({"service": name, "status": "unhealthy", "details": {"error": f"Bad response: {e}"}})
```

### Bug 3: Missing try/except in retry logic
```python
# BROKEN: No error handling — crashes on first failure
response = check_endpoint(name, url)

# FIXED: Wrap in try/except with proper handling
try:
    response = check_endpoint(name, url)
    health = parse_health_response(response)
    service_result["status"] = "healthy"
    service_result["details"] = health
    break
except (ConnectionError, ServiceCheckError) as e:
    if attempt == max_retries - 1:
        service_result["status"] = "unhealthy"
        service_result["details"] = {"error": f"Failed after {max_retries} retries: {e}"}
    time.sleep(1)  # Brief pause before retry
```

---

## Key Takeaways

1. **Never use bare `except:`** — always specify exception types
2. **Catch the right exception** — check what the function actually raises
3. **Preserve error information** — log it, include in results, or re-raise
4. **Use `finally:` for cleanup** — runs whether or not an exception occurred
5. **Custom exceptions** (`ServiceCheckError`) make error handling more precise
