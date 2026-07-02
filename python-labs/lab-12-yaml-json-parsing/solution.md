# Solution: Lab 12 — YAML/JSON Parsing

## Root Cause

### Bug 1: safe_load() vs safe_load_all() for multi-document YAML
```python
# BROKEN: safe_load only reads the first document (before second ---)
documents = yaml.safe_load(content)

# FIXED: safe_load_all returns a generator of all documents
documents = list(yaml.safe_load_all(content))
```

### Bug 2: YAML `yes`/`no` → boolean coercion
```yaml
# In YAML, these unquoted values become booleans:
env:
- name: DEBUG
  value: yes    # Becomes Python True (bool), not string "yes"
- name: ENABLE_METRICS
  value: no     # Becomes Python False (bool), not string "no"

# FIX in YAML — quote the values:
- name: DEBUG
  value: "yes"
- name: ENABLE_METRICS
  value: "no"
```

In Python, check with isinstance:
```python
if isinstance(value, bool):
    issues.append(f"  ⚠️  {key}={value} (bool — quote in YAML to keep as string)")
```

### Bug 3: YAML unquoted number → int coercion
```yaml
# YAML without quotes:
- name: PORT
  value: 8080     # Becomes Python int 8080, not string "8080"

# FIX:
- name: PORT
  value: "8080"   # Quoted = stays as string
```

---

## Fixed YAML file
```yaml
env:
- name: DEBUG
  value: "yes"
- name: ENABLE_METRICS
  value: "no"
- name: PORT
  value: "8080"
```

## Fixed Python code
```python
def parse_kubernetes_yaml(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    documents = list(yaml.safe_load_all(content))
    return documents

def check_yaml_gotchas(env_vars):
    issues = []
    for key, value in env_vars.items():
        if isinstance(value, bool):
            issues.append(f"{key}={value} (YAML converted yes/no to boolean!)")
        elif isinstance(value, int):
            issues.append(f"{key}={value} (YAML converted to int — quote it!)")
    return issues
```

---

## Key Takeaways

1. **`yaml.safe_load_all()`** for multi-document YAML (files with `---` separators)
2. **YAML converts `yes`/`no`/`on`/`off` to booleans** — always quote these values
3. **YAML converts unquoted numbers to int/float** — quote them if you want strings
4. **`json.load(file)` vs `json.loads(string)`** — know which to use
5. **Always use `yaml.safe_load()`** not `yaml.load()` — unsafe load can execute arbitrary code
