# Lab 15: Packaging & Venv — Python Package Structure

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-15/broken_script.py
vim /tmp/python-lab-15/src/mytools/__init__.py
vim /tmp/python-lab-15/setup.py
cd /tmp/python-lab-15 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python Packaging, Virtual Environments, and Import Paths**

When you graduate from single-file scripts to multi-file projects, you need to understand:

- **Package structure**: A directory with `__init__.py` becomes an importable package
- **`sys.path`**: Python only finds imports from directories in this list
- **Virtual environments**: Isolated Python environments (`python -m venv .venv`) prevent dependency conflicts
- **`pip install -e .`**: Editable install — lets you import your package while developing
- **`setup.py` / `pyproject.toml`**: Define your package metadata and dependencies
- **`package_dir`**: Tells setuptools where your source code lives (usually `src/`)

Common issues:
- Wrong `package_dir` in setup.py — points to non-existent directory
- `__init__.py` imports from submodules that don't exist
- Case sensitivity: Python is case-sensitive for imports!
- Running scripts directly vs importing as installed packages requires different path setups

---

## 🔧 Scenario

A DevOps toolkit package with utility functions (`format_bytes`, `get_system_stats`, `DevOpsToolkit`). The package lives in `src/mytools/` but has broken imports and packaging configuration.

---

## 💥 Error Output

```
Traceback (most recent call last):
  File "broken_script.py", line 15, in <module>
    from mytools import format_bytes, get_system_stats, DevOpsToolkit
ModuleNotFoundError: No module named 'mytools'
```

After fixing the path, you'll hit import errors inside the package.

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Python can't find `mytools` because it's inside `src/`. You need to either add `src/` to `sys.path` or install the package. For quick testing, modify `sys.path` at the top of the script.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three issues:
1. `broken_script.py` imports from `mytools` but doesn't add `src/` to `sys.path` — Python doesn't know to look there
2. `__init__.py` imports from `mytools.helpers` and `mytools.system` — but those submodules don't exist! The functions are defined directly in `__init__.py`
3. The class is defined as `DevopsToolkit` but imported as `DevOpsToolkit` (capital O)
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. In `broken_script.py`, add before the import:
   ```python
   sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "src"))
   ```
2. In `__init__.py`, remove the two broken import lines:
   ```python
   from mytools.helpers import format_bytes  # DELETE
   from mytools.system import get_system_stats  # DELETE
   ```
3. In `__init__.py`, change `class DevopsToolkit:` to `class DevOpsToolkit:`
</details>

---

## 📖 Python Docs Reference

- [Packages](https://docs.python.org/3/tutorial/modules.html#packages)
- [venv module](https://docs.python.org/3/library/venv.html)
- [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/)
- [pyproject.toml](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/)
- [pip install -e](https://pip.pypa.io/en/stable/cli/pip_install/#editable-installs)

---

## Difficulty: ⭐⭐⭐⭐ Expert

**Expected time:** 10-15 minutes  
**Bugs to find:** 3+ (across multiple files)  
**Concept:** Python packaging, import paths, virtual environments
