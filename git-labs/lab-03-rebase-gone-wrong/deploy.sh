#!/bin/bash
# Lab 03: Rebase Gone Wrong
# Creates a repo stuck in mid-rebase state with conflicts
set -e

LAB_DIR="/tmp/git-lab-03"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create main with a series of commits
cat > app.py <<'EOF'
def main():
    print("Hello World")
    return 0
EOF
git add app.py
git commit -m "Initial: basic main function"

cat > app.py <<'EOF'
def main():
    print("Hello World v2")
    config = load_config()
    return 0

def load_config():
    return {"debug": False}
EOF
git add app.py
git commit -m "Main: added load_config"

cat > app.py <<'EOF'
def main():
    print("Hello World v3")
    config = load_config()
    db = connect_db(config)
    return 0

def load_config():
    return {"debug": False, "db_host": "localhost"}

def connect_db(config):
    return f"connected to {config['db_host']}"
EOF
git add app.py
git commit -m "Main: added connect_db"

cat > app.py <<'EOF'
def main():
    print("Hello World v4 - Production")
    config = load_config()
    db = connect_db(config)
    server = start_server(config, db)
    return 0

def load_config():
    return {"debug": False, "db_host": "localhost", "port": 8080}

def connect_db(config):
    return f"connected to {config['db_host']}"

def start_server(config, db):
    return f"server on port {config['port']}"
EOF
git add app.py
git commit -m "Main: added start_server"

# Create feature branch from initial commit
git checkout -b feature HEAD~3

cat > app.py <<'EOF'
def main():
    print("Feature: Hello World")
    setup_logging()
    return 0

def setup_logging():
    return "logging enabled"
EOF
git add app.py
git commit -m "Feature: added setup_logging"

cat > app.py <<'EOF'
def main():
    print("Feature: Hello World v2")
    setup_logging()
    validate_env()
    return 0

def setup_logging():
    return "logging enabled"

def validate_env():
    import os
    return os.getenv("APP_ENV", "development")
EOF
git add app.py
git commit -m "Feature: added validate_env"

cat > app.py <<'EOF'
def main():
    print("Feature: Hello World v3 - Complete")
    setup_logging()
    validate_env()
    cache = init_cache()
    return 0

def setup_logging():
    return "logging enabled"

def validate_env():
    import os
    return os.getenv("APP_ENV", "development")

def init_cache():
    return {"ttl": 300}
EOF
git add app.py
git commit -m "Feature: added init_cache"

# Now start a rebase onto main — this will cause conflicts
# We use expect-like behavior by providing merge resolution that stops
git rebase main 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 03: Rebase Gone Wrong"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  A developer tried to rebase their feature branch (3 commits)"
echo "  onto main (which has 3 newer commits). The rebase hit conflicts"
echo "  on the very first commit and is now stuck in mid-rebase state."
echo ""
echo "  The working directory is messy with conflict markers."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Either:"
echo "  a) Abort the rebase and find a better approach"
echo "  b) Resolve the conflicts and continue the rebase"
echo ""
echo "CURRENT STATE:"
echo "  git status shows 'rebase in progress'"
echo "  app.py has conflict markers"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git status"
echo "  cat app.py   # See the conflict markers"
echo ""
