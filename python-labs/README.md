# 🐍 Python Troubleshooting Labs - Learn Python by Fixing Broken Code

## Learn Python by Debugging Real-World Broken Scripts (DevOps-Focused)

---

## Overview

This collection contains **15 intentionally broken Python scripts** designed for DevOps engineers who want to learn Python by doing what they do best — troubleshooting. Each lab presents a realistic DevOps automation script with bugs that teach fundamental Python concepts.

Instead of reading tutorials, you'll **run broken code, read the traceback, diagnose the issue, and fix it**. Every lab is themed around real DevOps tasks: parsing Kubernetes configs, calling APIs, managing servers, processing logs, and automating infrastructure.

The labs progress from beginner to advanced, building on concepts from previous labs.

---

## 📋 Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Python | 3.8+ | `python3 --version` |
| pip | Latest | `pip3 --version` |
| bash | 4.0+ | `bash --version` |

Optional (for specific labs):
- `requests` library (lab-11)
- `pyyaml` library (lab-12)
- Network access (lab-11, lab-13)

---

## 🚀 How to Use

### Single Lab:
```bash
# 1. Navigate to a lab
cd python-labs/lab-01-syntax-errors/

# 2. Deploy the lab (copies to /tmp and runs the broken script)
./deploy.sh

# 3. Read the error output carefully!
# 4. Open the broken script and fix it
vim /tmp/python-lab-01/broken_script.py

# 5. Run again to verify your fix
cd /tmp/python-lab-01 && python3 broken_script.py

# 6. Clean up when done
cd - && ./cleanup.sh
```

### All Labs:
```bash
# Deploy all labs
./deploy-all.sh

# Clean up all labs
./cleanup-all.sh
```

### Workflow:
1. **Run** → See the error
2. **Read** → Understand the traceback
3. **Diagnose** → Identify the root cause
4. **Fix** → Edit the script
5. **Verify** → Run again, confirm it works
6. **Learn** → Read the README for the concept explanation

---

## 🗂️ Lab Index

| # | Lab | Difficulty | Python Concept | Error Types |
|---|-----|-----------|----------------|-------------|
| 01 | [Syntax Errors](lab-01-syntax-errors/) | ⭐ Beginner | Syntax rules, indentation | IndentationError, SyntaxError |
| 02 | [Type Errors](lab-02-type-errors/) | ⭐ Beginner | Types, conversion | TypeError |
| 03 | [Import Errors](lab-03-import-errors/) | ⭐ Beginner | Modules, packages | ModuleNotFoundError, ImportError |
| 04 | [File Handling](lab-04-file-handling/) | ⭐⭐ Intermediate | File I/O, context managers | FileNotFoundError, PermissionError |
| 05 | [Dictionary Errors](lab-05-dictionary-errors/) | ⭐⭐ Intermediate | Dicts, JSON parsing | KeyError, TypeError |
| 06 | [List Operations](lab-06-list-operations/) | ⭐⭐ Intermediate | Lists, comprehensions | IndexError, RuntimeError |
| 07 | [String Formatting](lab-07-string-formatting/) | ⭐⭐ Intermediate | Strings, regex | KeyError, re errors |
| 08 | [Exception Handling](lab-08-exception-handling/) | ⭐⭐ Intermediate | try/except, custom errors | Silent failures, wrong catches |
| 09 | [Classes & OOP](lab-09-class-and-oop/) | ⭐⭐⭐ Advanced | OOP, inheritance | TypeError, AttributeError |
| 10 | [Subprocess & OS](lab-10-subprocess-and-os/) | ⭐⭐⭐ Advanced | subprocess, os, shlex | CalledProcessError, FileNotFoundError |
| 11 | [API Requests](lab-11-api-requests/) | ⭐⭐⭐ Advanced | HTTP, REST APIs | ConnectionError, JSONDecodeError |
| 12 | [YAML/JSON Parsing](lab-12-yaml-json-parsing/) | ⭐⭐⭐ Advanced | yaml, json modules | YAMLError, type coercion |
| 13 | [Async & Threading](lab-13-async-and-threading/) | ⭐⭐⭐⭐ Expert | asyncio, threading | RuntimeError, race conditions |
| 14 | [Decorators & Generators](lab-14-decorators-and-generators/) | ⭐⭐⭐⭐ Expert | Decorators, yield | StopIteration, lost metadata |
| 15 | [Packaging & Venv](lab-15-packaging-and-venv/) | ⭐⭐⭐⭐ Expert | pip, venv, pyproject.toml | ImportError, build failures |

---

## 📚 Python Concepts Covered

### Beginner (Labs 1-3)
- Python syntax: indentation, colons, quotes
- Data types: int, str, float, bool, type conversion
- Import system: modules, packages, sys.path, virtual environments

### Intermediate (Labs 4-8)
- File I/O: open(), with statement, encoding, paths
- Data structures: dicts, lists, sets, comprehensions
- String operations: f-strings, .format(), regex, raw strings
- Error handling: try/except/finally, custom exceptions, raise

### Advanced (Labs 9-12)
- OOP: classes, inheritance, super(), properties, dunder methods
- System interaction: subprocess, os, shlex, shell commands
- Networking: HTTP requests, REST APIs, authentication, timeouts
- Config parsing: YAML, JSON, type coercion, multi-document

### Expert (Labs 13-15)
- Concurrency: asyncio, threading, GIL, locks, race conditions
- Metaprogramming: decorators, generators, closures, functools
- Packaging: venv, pip, pyproject.toml, editable installs

---

## 🔥 Quick Reference: Common Python Errors

| Error | What It Means | Common Fix |
|-------|---------------|------------|
| `IndentationError` | Inconsistent spacing (tabs vs spaces) | Use 4 spaces consistently |
| `SyntaxError` | Invalid Python syntax | Check colons, brackets, quotes |
| `TypeError` | Wrong type in operation (e.g., str + int) | Use int(), str(), or f-strings |
| `ModuleNotFoundError` | Package not installed or wrong name | `pip install <package>` |
| `ImportError` | Can't import a name from a module | Check spelling, circular imports |
| `FileNotFoundError` | File path doesn't exist | Check path, use os.path.exists() |
| `PermissionError` | No read/write permission | Check file permissions (chmod) |
| `KeyError` | Dict key doesn't exist | Use dict.get(key, default) |
| `IndexError` | List index out of range | Check len(), use try/except |
| `AttributeError` | Object doesn't have that attribute | Check type, spelling, dir() |
| `ValueError` | Right type, wrong value | Validate input before use |
| `NameError` | Variable not defined | Check spelling, scope |
| `JSONDecodeError` | Invalid JSON string | Validate JSON format |
| `ConnectionError` | Network request failed | Check URL, timeout, retry |
| `RuntimeError` | Generic runtime failure | Read the message carefully |

---

## 📊 Progress Tracker

| Lab | Status | Time Taken | Notes |
|-----|--------|-----------|-------|
| Lab 01 - Syntax Errors | ☐ | ___ min | |
| Lab 02 - Type Errors | ☐ | ___ min | |
| Lab 03 - Import Errors | ☐ | ___ min | |
| Lab 04 - File Handling | ☐ | ___ min | |
| Lab 05 - Dictionary Errors | ☐ | ___ min | |
| Lab 06 - List Operations | ☐ | ___ min | |
| Lab 07 - String Formatting | ☐ | ___ min | |
| Lab 08 - Exception Handling | ☐ | ___ min | |
| Lab 09 - Classes & OOP | ☐ | ___ min | |
| Lab 10 - Subprocess & OS | ☐ | ___ min | |
| Lab 11 - API Requests | ☐ | ___ min | |
| Lab 12 - YAML/JSON Parsing | ☐ | ___ min | |
| Lab 13 - Async & Threading | ☐ | ___ min | |
| Lab 14 - Decorators & Generators | ☐ | ___ min | |
| Lab 15 - Packaging & Venv | ☐ | ___ min | |

---

## 💡 Tips for Success

1. **Read the full traceback** — Python tracebacks read bottom-to-top. The last line is the error, the lines above show the call stack.
2. **Use `python3 -i script.py`** — Drops you into interactive mode after a crash so you can inspect variables.
3. **Use `type()`** — When you get a TypeError, print `type(variable)` to see what you're actually working with.
4. **Use `dir()`** — Shows all attributes/methods of an object.
5. **Check Python version** — Some features (walrus operator, f-strings) require specific versions.
6. **Read the docs** — Python's official docs are excellent: https://docs.python.org/3/

---

## ⚔️ Rules of Engagement

1. **Don't look at solution.md** before trying to fix the script
2. Run `deploy.sh` → read the error → fix the script → verify
3. Time yourself — aim for under 5 minutes per beginner lab, under 10 for advanced
4. If stuck for 5+ minutes, read the hints in the lab README (they're progressive)
5. After fixing, read the solution.md to ensure you understand the underlying concept

---

## 📁 Directory Structure

```
python-labs/
├── README.md                          # This file
├── deploy-all.sh                      # Deploy all labs
├── cleanup-all.sh                     # Clean up all labs
├── lab-01-syntax-errors/              # Beginner: Python syntax
├── lab-02-type-errors/                # Beginner: Type conversion
├── lab-03-import-errors/              # Beginner: Import system
├── lab-04-file-handling/              # Intermediate: File I/O
├── lab-05-dictionary-errors/          # Intermediate: Dicts & JSON
├── lab-06-list-operations/            # Intermediate: Lists
├── lab-07-string-formatting/          # Intermediate: Strings & regex
├── lab-08-exception-handling/         # Intermediate: Error handling
├── lab-09-class-and-oop/              # Advanced: OOP
├── lab-10-subprocess-and-os/          # Advanced: System commands
├── lab-11-api-requests/               # Advanced: HTTP/REST
├── lab-12-yaml-json-parsing/          # Advanced: Config parsing
├── lab-13-async-and-threading/        # Expert: Concurrency
├── lab-14-decorators-and-generators/  # Expert: Metaprogramming
└── lab-15-packaging-and-venv/         # Expert: Packaging
```

---

## 🤝 Contributing

Want to add more broken Python scripts? PRs welcome! Each lab needs:
- A `broken_script.py` with intentional bugs (commented to show intent)
- A `README.md` with hints (no spoilers!)
- A `solution.md` with the fix and explanation
- `deploy.sh` and `cleanup.sh` scripts

---

## 📜 License

MIT License — break things freely, fix them wisely.

---

Happy debugging! 🐍🔧
