# Lab 04: File Handling — File I/O & Context Managers

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-04/broken_script.py
cd /tmp/python-lab-04 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python File I/O and Context Managers**

File handling is fundamental to DevOps scripting — reading configs, writing logs, processing data files. Common pitfalls include:

- **FileNotFoundError**: Path doesn't exist — always check first or handle the exception
- **PermissionError**: No read/write access — check file permissions
- **Resource leaks**: Opening a file without closing it can cause data loss or file locking
- **Encoding mismatches**: Reading UTF-8 file as UTF-16 produces garbage or errors
- **Missing directories**: `open()` can't create parent directories

The **context manager** pattern (`with open(...) as f:`) is the Pythonic solution:
- Automatically closes the file when the block exits
- Closes even if an exception occurs (like `try/finally`)
- Prevents resource leaks

Use `os.makedirs(path, exist_ok=True)` to create directories before writing.

---

## 🔧 Scenario

You have a DevOps script that manages server configuration files:
1. Reads an existing config
2. Updates some values (log level, workers)
3. Writes the updated config to a new file
4. Reads it back to verify correctness

---

## 💥 Error Output

```
Configuration File Manager
========================================

📖 Reading configuration...
Traceback (most recent call last):
  File "broken_script.py", line 85, in <module>
    main()
  File "broken_script.py", line 71, in main
    config = read_config(sample_path)
  File "broken_script.py", line 22, in read_config
    f = open("/etc/nonexistent/app.conf", 'r')
FileNotFoundError: [Errno 2] No such file or directory: '/etc/nonexistent/app.conf'
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

The `read_config()` function ignores the `filepath` parameter and tries to open a hardcoded path that doesn't exist. It should use the parameter.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `read_config()` uses a hardcoded path instead of the `filepath` parameter, and doesn't use a context manager
2. `write_config()` tries to write to a directory that doesn't exist (no `os.makedirs`)
3. `verify_config()` reads with `encoding='utf-16'` but the file was written as UTF-8 (the default)
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. In `read_config()`: Replace hardcoded path with `filepath`, use `with open(filepath, 'r') as f:`
2. In `write_config()`: Add `os.makedirs(output_dir, exist_ok=True)` before opening the file, and use a `with` statement
3. In `verify_config()`: Change `encoding='utf-16'` to `encoding='utf-8'` (or just remove the encoding param to use default)
</details>

---

## 📖 Python Docs Reference

- [Reading and Writing Files](https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files)
- [Context Managers (with statement)](https://docs.python.org/3/reference/compound_stmts.html#the-with-statement)
- [os.path](https://docs.python.org/3/library/os.path.html)
- [os.makedirs](https://docs.python.org/3/library/os.html#os.makedirs)

---

## Difficulty: ⭐⭐ Intermediate

**Expected time:** 5-7 minutes  
**Bugs to find:** 3  
**Concept:** File I/O, context managers, paths, encoding
