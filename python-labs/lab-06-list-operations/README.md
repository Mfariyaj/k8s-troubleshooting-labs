# Lab 06: List Operations — Indexing, Slicing & Comprehensions

## How to Use This Lab

```bash
./deploy.sh
vim /tmp/python-lab-06/broken_script.py
cd /tmp/python-lab-06 && python3 broken_script.py
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python Lists: Indexing, Mutation, and Comprehensions**

Lists are Python's most versatile data structure. Key pitfalls:

- **Never modify a list while iterating over it** — Python skips items because the indices shift. Use a list comprehension to create a new filtered list instead.
- **IndexError** — accessing an index that doesn't exist. Always check `len()` or use `try/except`.
- **Off-by-one errors** — remember Python is 0-indexed, `range(5)` is `[0,1,2,3,4]`.
- **`list.append()` vs overwriting** — `groups[key] = [item]` overwrites; you need `groups.setdefault(key, []).append(item)` or check first.

Best practices:
- Filter with list comprehension: `active = [s for s in servers if s["status"] == "active"]`
- Use `min(count, len(list))` to prevent IndexError
- Use slicing: `sorted_list[:count]` automatically handles short lists
- Use `enumerate()` when you need both index and value

---

## 🔧 Scenario

A server inventory management script that filters active servers, groups them by environment, finds the top servers by RAM, and calculates total resources. The data represents a typical infrastructure setup.

---

## 💥 Error Output

The script may not crash immediately, but produces **wrong output**:
- Decommissioned servers aren't all removed (one slips through)
- Environment grouping shows only 1 server per group
- If you request top 15 from a list of 8, you get an IndexError

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Run the script and look at the "Active servers" count and "Environments" output. The numbers don't add up. A decommissioned server is still present, and production should have more than 1 server.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

Three bugs:
1. `filter_active_servers()` removes items while iterating — this skips items. The second decommissioned server is never checked.
2. `get_top_servers_by_ram()` uses a loop with `range(count)` — crashes if count > list length.
3. `group_by_environment()` uses `groups[env] = [server]` — this overwrites the list with only the last server each time.
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Replace the mutation-while-iterating pattern with:
   `return [s for s in servers if s["status"] != "decommissioned"]`
2. Replace the loop with slicing: `return sorted_servers[:count]` (slicing beyond length returns what's available)
3. Use `setdefault`: `groups.setdefault(env, []).append(server)` or check `if env not in groups: groups[env] = []`
</details>

---

## 📖 Python Docs Reference

- [List Data Structure](https://docs.python.org/3/tutorial/datastructures.html)
- [List Comprehensions](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions)
- [sorted()](https://docs.python.org/3/library/functions.html#sorted)
- [Slice notation](https://docs.python.org/3/library/functions.html#slice)

---

## Difficulty: ⭐⭐ Intermediate

**Expected time:** 5-8 minutes  
**Bugs to find:** 3  
**Concept:** List mutation, indexing safety, comprehensions
