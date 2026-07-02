# Lab 01: Solution — Merge Conflict Resolution

## Root Cause

Three branches all modified the same lines in the same files. Git cannot automatically determine which version to keep when the same line has different changes in different branches.

## Fix Commands

```bash
cd /tmp/git-lab-01

# Step 1: Merge feature-a (merges cleanly — no conflicts with main)
git merge feature-a -m "Merge feature-a into main"

# Step 2: Merge feature-b (will conflict)
git merge feature-b
# CONFLICT! Edit files to resolve:

# For each conflicted file, open and resolve conflict markers
# Example resolution for config.yaml — keep v2.0 version with debug:
cat > config.yaml <<'EOF'
# Application Configuration
app:
  name: myapp
  version: 2.0.0
  port: 9090
  host: localhost

database:
  host: localhost
  port: 5432
  name: myapp_db
  pool_size: 20

logging:
  level: debug
  format: json
  output: stdout
EOF

# Resolve app.py — keep v2.0 with higher connections
cat > app.py <<'EOF'
#!/usr/bin/env python3
"""Main application module."""

def get_config():
    """Load application configuration."""
    return {
        "app_name": "myapp",
        "version": "2.0.0",
        "debug": True,
        "max_connections": 500,
    }

def start_server(config):
    """Start the application server."""
    print(f"Starting {config['app_name']} v{config['version']}")
    print(f"Debug mode: {config['debug']}")
    return True

if __name__ == "__main__":
    config = get_config()
    start_server(config)
EOF

# Mark resolved and commit
git add config.yaml app.py README.md
git commit -m "Merge feature-b: resolved conflicts, keeping v2.0 settings with debug"

# Step 3: Merge feature-c (will conflict again)
git merge feature-c
# Resolve conflicts again — incorporate production settings:

cat > config.yaml <<'EOF'
# Application Configuration
app:
  name: myapp
  version: 2.0.0
  port: 8443
  host: 0.0.0.0

database:
  host: localhost
  port: 5432
  name: production_db
  pool_size: 20

logging:
  level: debug
  format: json
  output: stdout
EOF

git add .
git commit -m "Merge feature-c: production-ready config with v2.0"
```

## Git Internals Explained

### How Merge Conflicts Work

1. **Three-way merge**: Git finds the common ancestor (merge base) of the two branches being merged, then compares both branches' changes against it.

2. **Conflict detection**: If both branches modified the same hunk (contiguous block of lines), Git cannot auto-resolve and marks it as conflicted.

3. **Conflict markers**:
   - `<<<<<<< HEAD` — your current branch's version
   - `=======` — separator
   - `>>>>>>> branch-name` — incoming branch's version

4. **Resolution**: You edit the file to contain the desired final content, remove all markers, then `git add` to mark it resolved.

### Merge Strategies

- `git merge -s recursive` (default): Best for merging two branches
- `git merge -s octopus`: Merges multiple branches at once (but won't handle conflicts)
- `git merge -X ours`: Auto-resolve conflicts by preferring current branch
- `git merge -X theirs`: Auto-resolve conflicts by preferring incoming branch

### Tips for Complex Merges

- Use `git merge --no-commit` to stage without committing, allowing review
- Use `git diff --cached` to see what the merge result looks like before committing
- Use `git checkout -p --theirs <file>` for hunk-by-hunk selection
- Use `git mergetool` to launch a visual merge tool
