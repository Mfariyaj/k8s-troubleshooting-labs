#!/bin/bash
# Lab 01: Merge Conflict Resolution
# Creates a repo with conflicting changes across 3 branches
set -e

LAB_DIR="/tmp/git-lab-01"

# Clean up any existing lab
rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

# Initialize repo
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create initial files on main
cat > config.yaml <<'EOF'
# Application Configuration
app:
  name: myapp
  version: 1.0.0
  port: 8080
  host: localhost

database:
  host: localhost
  port: 5432
  name: myapp_db
  pool_size: 5

logging:
  level: info
  format: json
  output: stdout
EOF

cat > app.py <<'EOF'
#!/usr/bin/env python3
"""Main application module."""

def get_config():
    """Load application configuration."""
    return {
        "app_name": "myapp",
        "version": "1.0.0",
        "debug": False,
        "max_connections": 100,
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

cat > README.md <<'EOF'
# MyApp

A simple application for demonstration.

## Setup
1. Install dependencies
2. Run `python3 app.py`

## Configuration
Edit `config.yaml` to customize settings.
EOF

git add .
git commit -m "Initial commit: base application setup"

# Create feature-a branch with changes
git checkout -b feature-a
sed -i 's/version: 1.0.0/version: 2.0.0/' config.yaml
sed -i 's/port: 8080/port: 9090/' config.yaml
sed -i 's/pool_size: 5/pool_size: 20/' config.yaml
sed -i 's/"version": "1.0.0"/"version": "2.0.0"/' app.py
sed -i 's/"debug": False/"debug": True/' app.py
sed -i 's/"max_connections": 100/"max_connections": 500/' app.py
cat >> README.md <<'EOF'

## Version 2.0 Changes
- Increased connection pool
- New port: 9090
- Debug mode enabled for development
EOF
git add .
git commit -m "feature-a: upgrade to v2.0 with new settings"

# Go back to main and create feature-b with conflicting changes
git checkout main
git checkout -b feature-b
sed -i 's/version: 1.0.0/version: 1.5.0/' config.yaml
sed -i 's/port: 8080/port: 3000/' config.yaml
sed -i 's/pool_size: 5/pool_size: 10/' config.yaml
sed -i 's/level: info/level: debug/' config.yaml
sed -i 's/"version": "1.0.0"/"version": "1.5.0"/' app.py
sed -i 's/"debug": False/"debug": True/' app.py
sed -i 's/"max_connections": 100/"max_connections": 250/' app.py
cat >> README.md <<'EOF'

## Version 1.5 Changes
- Debug logging enabled
- Port changed to 3000
- Connection pool increased to 10
EOF
git add .
git commit -m "feature-b: v1.5 with debug logging and new port"

# Go back to main and create feature-c with more conflicts
git checkout main
git checkout -b feature-c
sed -i 's/host: localhost/host: 0.0.0.0/' config.yaml
sed -i 's/port: 8080/port: 8443/' config.yaml
sed -i 's/name: myapp_db/name: production_db/' config.yaml
sed -i 's/"app_name": "myapp"/"app_name": "myapp-prod"/' app.py
sed -i 's/"max_connections": 100/"max_connections": 1000/' app.py
sed -i 's/# MyApp/# MyApp Production/' README.md
git add .
git commit -m "feature-c: production-ready configuration"

# Switch to main - user needs to merge all three
git checkout main

echo ""
echo "============================================="
echo "🔧 Lab 01: Merge Conflict Resolution"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  Three feature branches (feature-a, feature-b, feature-c) all"
echo "  modify the same files (config.yaml, app.py, README.md) with"
echo "  conflicting changes. You need to merge ALL three into main."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Merge all three branches into main, resolving all conflicts."
echo "  The final result should be a coherent configuration."
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git log --oneline --graph --all"
echo "  git merge feature-a"
echo ""
