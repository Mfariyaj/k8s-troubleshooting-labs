# Lab 14: Decorators & Generators — Advanced Python Patterns

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-14/broken_script.py
cd /tmp/python-lab-14 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Decorators and Generators**

These are two of Python's most powerful features, commonly used in DevOps automation:

**Decorators** — modify function behavior without changing the function code. Common uses:
- Retry logic for flaky network calls
- Timing/profiling
- Authentication checks
- Caching results

The key pattern is: `def decorator(func)` returns a `wrapper(*args, **kwargs)` that calls `func()` with added behavior. Always use `@functools.wraps(func)` to preserve the original function's name and docstring.

**Generators** — produce values lazily using `yield`. They're memory-efficient for processing large data (log files, API pagination). But they're **single-use** — once you iterate through a generator, it's empty forever.

Key gotcha: If you need to iterate over the same data twice, either:
1. Call the generator function again (creates a new generator)
2. Convert to a list first: `data = list(generator_func())`

---

## 🔧 Scenario

A DevOps automation script with two parts:
1. A retry decorator for flaky service deployments
2. A log processing pipeline using generators

---

## 💥 Error Output

The script runs but produces incorrect results:
```
📋 Function metadata check:
  Function name: wrapper
  Function doc: None
  ⚠️  BUG: Function name is 'wrapper' — @functools.wraps is missing!

📊 Log Processing:
  Total log entries: 9
  Error/Warning entries: 0
  ⚠️  BUG: Got 0 errors — generator was exhausted before second pass!
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

When you decorate a function, the wrapper function replaces the original. Without `@functools.wraps(func)`, the wrapper's name ("wrapper") and docstring (None) replace the original's. The fix is one line.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three issues:
1. Missing `@functools.wraps(func)` above the wrapper function definition inside the retry decorator
2. In `process_logs()`, `log_gen` is consumed by `list(log_gen)` on the first pass
3. The second `filter_errors(log_gen)` gets an exhausted generator and produces nothing
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Add `@functools.wraps(func)` on the line directly above `def wrapper(*args, **kwargs):`
2. For the generator issue, either:
   - Create two separate generators: `list(generate_log_lines())` and `list(filter_errors(generate_log_lines()))`
   - Or convert to list first, then filter from the list
</details>

---

## 📖 Python Docs Reference

- [functools.wraps](https://docs.python.org/3/library/functools.html#functools.wraps)
- [Decorators](https://docs.python.org/3/glossary.html#term-decorator)
- [Generators](https://docs.python.org/3/tutorial/classes.html#generators)
- [Generator Expressions](https://docs.python.org/3/reference/expressions.html#generator-expressions)

---

## Difficulty: ⭐⭐⭐⭐ Expert

**Expected time:** 10-12 minutes  
**Bugs to find:** 3 (1 decorator + 2 generator related)  
**Concept:** Decorators with @functools.wraps, generator single-use lifecycle
