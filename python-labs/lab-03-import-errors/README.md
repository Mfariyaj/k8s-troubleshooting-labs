# Lab 03: Import Errors — Modules, Packages & the Import System

## How to Use This Lab

```bash
./deploy.sh
# See the import errors, then investigate all .py files
vim /tmp/python-lab-03/broken_script.py
vim /tmp/python-lab-03/config.py
vim /tmp/python-lab-03/utils.py
cd /tmp/python-lab-03 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python's Import System**

When Python encounters `import X`, it searches for module `X` in this order:
1. Built-in modules (sys, os, etc.)
2. `sys.path` — which includes the current directory, installed packages, PYTHONPATH

Common import errors:
- **ModuleNotFoundError**: The module doesn't exist or isn't installed (check spelling!)
- **ImportError**: The module exists but the specific name you're importing doesn't
- **Circular imports**: Module A imports from B, and B imports from A — Python gets stuck

Circular imports happen when two modules depend on each other. The fix is to:
1. Move shared constants to a separate module
2. Import inside functions (lazy import) instead of at the top
3. Restructure to eliminate the cycle

The `requirements.txt` file lists package dependencies — typos there mean `pip install -r requirements.txt` will fail.

---

## 🔧 Scenario

You have a health checker with three files:
- `broken_script.py` — main script that imports from config and utils
- `config.py` — server list and settings
- `utils.py` — helper functions

The modules have import problems preventing the script from running.

---

## 💥 Error Output

```
Traceback (most recent call last):
  File "broken_script.py", line 14, in <module>
    import reqeusts
ModuleNotFoundError: No module named 'reqeusts'
```

After fixing that, you'll hit a circular import error.

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Look at the module name on line 14 very carefully. Is it spelled correctly? The popular HTTP library is called `requests`.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

There are 3 issues:
1. `import reqeusts` — typo in module name (and it's not even needed in this script)
2. `config.py` imports `DEFAULT_TIMEOUT` from `utils.py`
3. `utils.py` imports `SERVER_LIST` from `config.py`
This creates a circular dependency!
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Remove or fix the `import reqeusts` line (the script doesn't use requests)
2. Break the circular import: `utils.py` doesn't actually USE `SERVER_LIST` — it only defines `DEFAULT_TIMEOUT` and helper functions. Remove the `from config import SERVER_LIST` line from utils.py
3. In `config.py`, instead of importing DEFAULT_TIMEOUT from utils, just define `TIMEOUT = 5` directly
</details>

---

## 📖 Python Docs Reference

- [The Import System](https://docs.python.org/3/reference/import.html)
- [Modules Tutorial](https://docs.python.org/3/tutorial/modules.html)
- [sys.path](https://docs.python.org/3/library/sys.html#sys.path)
- [pip and requirements.txt](https://pip.pypa.io/en/stable/user_guide/#requirements-files)

---

## Difficulty: ⭐ Beginner

**Expected time:** 5-7 minutes  
**Bugs to find:** 3 (across multiple files)  
**Concept:** Python's import system and circular dependencies
