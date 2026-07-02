# Lab 01: Syntax Errors — Python Syntax Rules & Indentation

## How to Use This Lab

```bash
# Deploy the lab
./deploy.sh

# You'll see Python syntax errors in the output
# Open the broken script and fix all syntax issues
vim /tmp/python-lab-01/broken_script.py

# Run again to verify
cd /tmp/python-lab-01 && python3 broken_script.py

# Clean up
cd - && ./cleanup.sh
```

---

## 📚 What This Lab Teaches

**Python Syntax Fundamentals**

Python is a whitespace-sensitive language. Unlike C, Java, or JavaScript which use curly braces `{}` to define code blocks, Python uses **indentation**. This means:

- Every `if`, `for`, `while`, `def`, `class` statement must end with a colon `:`
- The body of these statements must be indented (standard is 4 spaces)
- All lines in the same block must have the same indentation level
- Mixing tabs and spaces will cause `IndentationError`
- Strings must have matching quotes (single `'...'` or double `"..."`)
- Parentheses, brackets, and braces must be properly closed

Python's syntax checking happens **before** the code runs, so syntax errors prevent any execution at all. The error message tells you the exact line and position where Python got confused.

Understanding Python tracebacks starts here — the line number in a `SyntaxError` points to where Python noticed the problem, which may be one line after the actual mistake.

---

## 🔧 Scenario

You've written a Python script that reads a server configuration file (`key=value` format), parses it into a dictionary, and displays a formatted summary. The script is supposed to:
1. Create a sample config file in `/tmp/`
2. Read and parse the config
3. Display settings grouped by category (server, db, other)
4. Validate that required keys are present

But the script has **3 syntax bugs** that prevent it from running at all.

---

## 💥 Error Output

When you run `python3 broken_script.py`, you'll see:

```
  File "broken_script.py", line 18
    def read_config(filepath)
                            ^
SyntaxError: expected ':'
```

After fixing that, you'll encounter more syntax errors on subsequent runs.

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>

Python function definitions require a specific character at the end of the `def` line. Look at line 18 carefully.
</details>

<details>
<summary>Hint 2 (More specific)</summary>

There are 3 bugs total:
1. A missing colon after a function definition (line 18)
2. An indentation error in a conditional block (around line 49)
3. Mismatched string quotes in a print statement (near the end)
</details>

<details>
<summary>Hint 3 (Almost the answer)</summary>

1. Line 18: `def read_config(filepath)` → needs `:` at the end
2. Line 49: `if key.startswith("server"):` — this line is not indented inside the `for` loop
3. Near line 95: A string starts with `'` but ends with `"` — quotes must match
</details>

---

## 📖 Python Docs Reference

- [Indentation](https://docs.python.org/3/reference/lexical_analysis.html#indentation)
- [Function Definitions](https://docs.python.org/3/tutorial/controlflow.html#defining-functions)
- [String Literals](https://docs.python.org/3/reference/lexical_analysis.html#string-and-bytes-literals)
- [Errors and Exceptions](https://docs.python.org/3/tutorial/errors.html)

---

## Difficulty: ⭐ Beginner

**Expected time:** 3-5 minutes  
**Bugs to find:** 3  
**Concept:** Python's indentation-based syntax
