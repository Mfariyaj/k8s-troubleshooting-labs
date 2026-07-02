# Solution: Lab 07 — String Formatting

## Root Cause

### Bug 1: .format() keyword mismatch
```python
# BROKEN: Template expects {environment} but receives env=
return template.format(app_name=app_name, version=version, env=environment, ...)

# FIXED: Match keyword to placeholder
return template.format(app_name=app_name, version=version, environment=environment, ...)
```

### Bug 2: Regex without raw string and unescaped brackets
```python
# BROKEN: [ ] are regex character class markers, \d is interpreted as escape
pattern = "[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}] (\w+): (.+)"

# FIXED: Use raw string (r"") and escape the literal brackets
pattern = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] (\w+): (.+)"
```

### Note on Bug 3: The `details` line with double braces
The `details` formatting with `{{` and `}}` is actually correct Python — double braces produce literal braces in `.format()` output. The result is `{passed: 3, failed: 1}` which is the intended output.

---

## Fixed Code

```python
def generate_header(app_name, version, environment):
    template = """
╔══════════════════════════════════════════════════╗
║  Deployment Report                               ║
║  App: {app_name}                                 ║
║  Version: {version}                              ║
║  Environment: {environment}                      ║
║  Date: {date}                                    ║
╚══════════════════════════════════════════════════╝
"""
    return template.format(
        app_name=app_name,
        version=version,
        environment=environment,  # FIX: keyword matches placeholder
        date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )


def parse_log_lines(log_text):
    # FIX: raw string + escaped brackets
    pattern = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] (\w+): (.+)"
    results = []
    for line in log_text.strip().split('\n'):
        match = re.search(pattern, line)
        if match:
            results.append({"level": match.group(1), "message": match.group(2)})
    return results
```

---

## Key Takeaways

1. **Always use `r""` for regex patterns** — prevents Python from interpreting `\d`, `\w`, etc.
2. **`.format()` keywords must match template placeholders exactly**
3. **Literal braces in .format()**: use `{{` and `}}` to produce `{` and `}` in output
4. **f-strings are simpler** — they auto-resolve variable names, no keyword matching needed
5. **Regex special chars**: `[ ] . * + ? { } ( ) | ^ $ \` all have meaning — escape with `\`
