# Lab 12: YAML/JSON Parsing — Config File Gotchas

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-12/broken_script.py
vim /tmp/python-lab-12/broken_config.yaml
cd /tmp/python-lab-12 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**YAML and JSON Parsing in Python**

YAML and JSON are the configuration languages of DevOps. Every K8s manifest, Terraform config, CI/CD pipeline, and Ansible playbook uses them.

Key YAML gotchas:
- **`yes`/`no` → boolean**: YAML 1.1 converts unquoted `yes`, `no`, `on`, `off`, `true`, `false` to booleans. Always quote values if you want strings!
- **Unquoted numbers → int/float**: `port: 8080` becomes integer 8080, not string "8080"
- **Multi-document YAML**: Files with `---` separators contain multiple documents. `safe_load()` only reads the first one; use `safe_load_all()`
- **Indentation matters**: Wrong indent changes the YAML structure entirely

JSON gotchas:
- **Trailing commas are invalid**: `{"key": "val",}` is NOT valid JSON
- **`null` vs missing key**: `"ip": null` is a valid entry (None in Python)
- **`json.load(file)` vs `json.loads(string)`**

Always use `yaml.safe_load()` — the plain `yaml.load()` can execute arbitrary Python code!

---

## 🔧 Scenario

A config parser that reads Kubernetes deployment YAML (multi-document with Deployment + Service) and Terraform state JSON. It should identify YAML type coercion issues and display infrastructure details.

---

## 💥 Error Output

```
☸️  Kubernetes Resources:
  📄 Deployment: web-app
     Environment variables: 4
       DEBUG=True (type: bool)
       ENABLE_METRICS=False (type: bool)
       LOG_LEVEL=INFO (type: str)
       PORT=8080 (type: int)
  ⚠️  Expected 2 documents (Deployment + Service) but only found 1!
     Check: Are you using safe_load_all() for multi-doc YAML?
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

The YAML file has `---` separators meaning it contains multiple documents. Which yaml function reads all documents from a multi-document file?
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three issues:
1. `yaml.safe_load()` → `yaml.safe_load_all()` — the former only reads one document
2. The YAML `value: yes` / `value: no` produces booleans. The detection code compares `value == "yes"` which will never match a boolean True
3. The YAML `value: 8080` (unquoted) produces an integer — the Python code should detect and report this
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Change `yaml.safe_load(content)` to `list(yaml.safe_load_all(content))` — returns list of all docs
2. Change `if value == "yes"` to `if isinstance(value, bool) and value == True` — or better: `if isinstance(value, bool)`
3. For the PORT issue: `if isinstance(value, int)` detects unquoted numbers. Fix the YAML by quoting: `value: "8080"`
</details>

---

## 📖 Python Docs Reference

- [json module](https://docs.python.org/3/library/json.html)
- [PyYAML Documentation](https://pyyaml.org/wiki/PyYAMLDocumentation)
- [YAML 1.1 Boolean Values](https://yaml.org/type/bool.html)

---

## Difficulty: ⭐⭐⭐ Advanced

**Expected time:** 7-10 minutes  
**Bugs to find:** 3 (Python code + YAML content)  
**Concept:** YAML/JSON parsing, type coercion, multi-document YAML
