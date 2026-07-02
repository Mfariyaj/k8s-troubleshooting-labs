# Lab 07: String Formatting — f-strings, .format(), and Regex

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-07/broken_script.py
cd /tmp/python-lab-07 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**String Formatting and Regular Expressions**

Python has multiple string formatting approaches:
- **f-strings** (Python 3.6+): `f"Hello {name}"` — best for inline formatting
- **.format()**: `"Hello {name}".format(name="World")` — keywords must match placeholders
- **% formatting**: `"Hello %s" % name` — old style, avoid in new code

Common regex pitfalls:
- **Raw strings**: Always use `r"pattern"` for regex — prevents `\d` being interpreted as escape
- **Square brackets in regex**: `[` has special meaning (character class) — escape as `\[`
- **Character classes**: `\d{4}` matches 4 digits, but only inside a raw string

The `re` module provides: `re.search()`, `re.match()`, `re.findall()`, `re.sub()`

Key `.format()` rules:
- Literal braces in output: use `{{` and `}}`
- Named placeholders must match keyword args exactly

---

## 🔧 Scenario

A deployment report generator that creates formatted reports, parses deployment logs with regex, and generates step-by-step summaries.

---

## 💥 Error Output

```
Generating deployment report...

Traceback (most recent call last):
  File "broken_script.py", line 99, in <module>
    main()
  File "broken_script.py", line 80, in main
    header = generate_header("payment-service", "v3.2.1", "production")
  File "broken_script.py", line 35, in generate_header
    return template.format(
KeyError: 'environment'
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

In `.format()`, the keyword argument names must exactly match the placeholders in the template string. Compare what the template expects vs what you're passing.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. Template uses `{environment}` but `.format()` receives `env=environment` — keyword doesn't match
2. Regex pattern has `[` and `]` that need escaping since they're character class markers; also needs `r""` raw string prefix
3. In `format_deployment_steps()`, the `details` string has double-braces `{{` `}}` which produce literal braces — but then the log parsing regex doesn't use a raw string
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Change `env=environment` to `environment=environment` in the `.format()` call
2. Change the regex pattern to: `r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] (\w+): (.+)"` — raw string + escaped brackets
3. The `details` line actually works but produces literal braces. If you want the output to look like `{passed: 3, failed: 1}` the existing double-brace is correct!
</details>

---

## 📖 Python Docs Reference

- [f-strings (PEP 498)](https://docs.python.org/3/reference/lexical_analysis.html#f-strings)
- [str.format()](https://docs.python.org/3/library/stdtypes.html#str.format)
- [re — Regular Expressions](https://docs.python.org/3/library/re.html)
- [Raw String Notation](https://docs.python.org/3/library/re.html#raw-string-notation)

---

## Difficulty: ⭐⭐ Intermediate

**Expected time:** 5-8 minutes  
**Bugs to find:** 3 (or 2 + verifying the third isn't actually a bug)  
**Concept:** String formatting methods and regex raw strings
