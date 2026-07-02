#!/bin/bash
# Lab 15: Git LFS Failures
# Creates a repo with LFS misconfiguration showing pointer files
set -e

LAB_DIR="/tmp/git-lab-15"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create .gitattributes for LFS WITHOUT initializing LFS
# This is the core of the problem: .gitattributes tells git to use LFS
# but git-lfs isn't set up in this repo
cat > .gitattributes <<'EOF'
*.bin filter=lfs diff=lfs merge=lfs -text
*.dat filter=lfs diff=lfs merge=lfs -text
*.model filter=lfs diff=lfs merge=lfs -text
assets/*.png filter=lfs diff=lfs merge=lfs -text
EOF

git add .gitattributes
git commit -m "Add LFS tracking rules"

# Create some source files (normal, not LFS)
mkdir -p src
cat > src/main.py <<'EOF'
#!/usr/bin/env python3
"""Machine learning pipeline."""
import os

def load_model(path):
    """Load ML model from file."""
    with open(path, 'rb') as f:
        return f.read()

def process_data(data_path):
    """Process training data."""
    with open(data_path, 'rb') as f:
        return f.read()

if __name__ == "__main__":
    model = load_model("models/trained.model")
    data = process_data("data/training.dat")
    print(f"Model size: {len(model)} bytes")
    print(f"Data size: {len(data)} bytes")
EOF
git add src/
git commit -m "Add main ML pipeline code"

# Now create files that SHOULD be in LFS but aren't handled properly
# Since LFS isn't installed/initialized, these will be stored as pointer files
# or as raw content in conflicting ways

mkdir -p models data assets

# Simulate what happens when LFS isn't properly set up:
# The files are committed as pointer file text instead of actual binary content
cat > models/trained.model <<'EOF'
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393
size 52428800
EOF

cat > data/training.dat <<'EOF'
version https://git-lfs.github.com/spec/v1
oid sha256:a3c25e8b1f2d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f
size 104857600
EOF

cat > assets/logo.png <<'EOF'
version https://git-lfs.github.com/spec/v1
oid sha256:1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b
size 2097152
EOF

# Also create a .bin file with actual random content (as if LFS was bypassed)
dd if=/dev/urandom of=data/embeddings.bin bs=1K count=100 2>/dev/null

git add .
git commit -m "Add ML models and training data"

# Create another commit on top to make history more complex
echo "v2.0 model" >> models/trained.model
cat > src/config.py <<'EOF'
MODEL_PATH = "models/trained.model"
DATA_PATH = "data/training.dat"
BATCH_SIZE = 32
EPOCHS = 100
EOF
git add .
git commit -m "Update model and add config"

# Break the LFS filter config (if any LFS is installed)
# This ensures even if git-lfs is present, it won't work correctly
git config --unset-all filter.lfs.clean 2>/dev/null || true
git config --unset-all filter.lfs.smudge 2>/dev/null || true
git config --unset-all filter.lfs.process 2>/dev/null || true
git config --unset-all filter.lfs.required 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 15: Git LFS Failures"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  This ML project repository has .gitattributes configured for"
echo "  Git LFS (*.bin, *.dat, *.model, assets/*.png), but LFS was"
echo "  never properly initialized. As a result:"
echo ""
echo "  - Model files show LFS POINTER TEXT instead of binary content"
echo "  - data/embeddings.bin was committed directly (100KB, bypassing LFS)"
echo "  - The filter.lfs config entries are missing from .git/config"
echo ""
echo "  When you run 'cat models/trained.model', you see pointer"
echo "  file content instead of actual model data."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Diagnose and fix the LFS configuration so that:"
echo "  1. git-lfs filter is properly configured"
echo "  2. LFS tracked patterns match .gitattributes"
echo "  3. Files show correct content (or clear guidance on how to pull)"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  cat models/trained.model     # Shows pointer, not binary!"
echo "  cat .gitattributes           # LFS patterns defined"
echo "  git config --list | grep lfs # Missing LFS config!"
echo "  git lfs status               # If git-lfs is installed"
echo ""
