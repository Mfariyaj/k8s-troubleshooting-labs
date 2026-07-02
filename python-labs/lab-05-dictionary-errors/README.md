# Lab 05: Dictionary Errors — Dicts, JSON, and Safe Access

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-05/broken_script.py
cd /tmp/python-lab-05 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Dictionaries, JSON Parsing, and Safe Key Access**

Dictionaries are Python's key-value data structure and are used extensively when working with JSON — which means they're everywhere in DevOps (Kubernetes API responses, Terraform state, cloud API outputs).

Common mistakes:
- **`json.loads()` vs `json.load()`**: `loads` parses strings, `load` parses file objects
- **`dict["key"]` vs `dict.get("key")`**: Direct access raises `KeyError` if missing; `.get()` returns `None`
- **Nested access**: `data["a"]["b"]["c"]` fails if any level is missing
- **Dynamic structure**: K8s/API responses have optional fields that vary per resource

Safe access patterns:
- `dict.get("key", "default")` — returns default if key missing
- `dict.get("a", {}).get("b", {}).get("c")` — safe nested access
- `try/except KeyError` — catch and handle missing keys

---

## 🔧 Scenario

This script parses a Kubernetes pod list JSON response (like from `kubectl get pods -o json`). It extracts pod names, statuses, container info, and restart counts to generate a status report.

---

## 💥 Error Output

```
Loading Kubernetes pod data...
Traceback (most recent call last):
  File "broken_script.py", line 87, in <module>
    main()
  File "broken_script.py", line 82, in main
    pod_data = load_pod_data(data_file)
  File "broken_script.py", line 20, in load_pod_data
    data = json.loads(f)
TypeError: the JSON object must be str, bytes or bytearray, not TextIOWrapper
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

`json.loads()` expects a string. `json.load()` expects a file object. Look at what `f` is in the function.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `json.loads(f)` should be `json.load(f)` — f is a file handle, not a string
2. `pod["metadata"]["labels"]["tier"]` — the second pod doesn't have a "tier" label
3. `container_status["state"]["running"]["startedAt"]` — the second pod is in "waiting" state, not "running"
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Change `json.loads(f)` to `json.load(f)`
2. Change direct access to: `pod["metadata"]["labels"].get("tier", "unknown")`
3. For the state, check which state exists:
   ```python
   state = container_status["state"]
   if "running" in state:
       start_time = state["running"]["startedAt"]
   else:
       start_time = "N/A"
   ```
</details>

---

## 📖 Python Docs Reference

- [json module](https://docs.python.org/3/library/json.html)
- [Dictionaries](https://docs.python.org/3/tutorial/datastructures.html#dictionaries)
- [dict.get()](https://docs.python.org/3/library/stdtypes.html#dict.get)

---

## Difficulty: ⭐⭐ Intermediate

**Expected time:** 5-7 minutes  
**Bugs to find:** 3  
**Concept:** Dictionary access, JSON parsing, handling optional fields
