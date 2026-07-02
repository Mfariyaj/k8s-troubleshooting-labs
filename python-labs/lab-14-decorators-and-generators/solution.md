# Solution: Lab 14 — Decorators and Generators

## Root Cause

### Bug 1: Missing @functools.wraps
```python
# BROKEN: Decorated function loses its __name__ and __doc__
def decorator(func):
    def wrapper(*args, **kwargs):
        ...
    return wrapper

# FIXED: Preserve metadata with @functools.wraps
def decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        ...
    return wrapper
```

### Bug 2 & 3: Generator exhaustion — consuming twice
```python
# BROKEN: Same generator used twice — second pass gets nothing
log_gen = generate_log_lines()
all_entries = list(log_gen)          # Consumes entire generator
error_entries = list(filter_errors(log_gen))  # Nothing left!

# FIXED: Create a new generator for the second pass
all_entries = list(generate_log_lines())  # First generator
error_entries = list(filter_errors(generate_log_lines()))  # Fresh generator

# OR: Convert to list first, then filter from the list
all_entries = list(generate_log_lines())
error_entries = [
    parse_log_entry(line) for line in all_entries 
    if parse_log_entry(line) and parse_log_entry(line)["level"] in ("ERROR", "WARN")
]
```

---

## Key Takeaways

1. **Always use `@functools.wraps(func)`** — preserves `__name__`, `__doc__`, and other metadata
2. **Generators are single-use** — once exhausted, they can't be reset. Create a new one for each pass.
3. **`list(generator)` consumes it** — if you need multiple passes, convert once and use the list
4. **`yield` makes a function a generator** — each call returns a fresh generator object
5. **Decorators with arguments** need three levels of nesting: `def retry(args)` → `def decorator(func)` → `def wrapper(*args)`
