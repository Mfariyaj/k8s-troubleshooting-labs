#!/bin/bash
# Lab 14: Sparse Checkout Broken
# Creates a monorepo with broken sparse checkout
set -e

LAB_DIR="/tmp/git-lab-14"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

# First, create a "remote" monorepo
SOURCE_DIR="$LAB_DIR/monorepo-source.git"
mkdir -p "$SOURCE_DIR"
cd "$SOURCE_DIR"
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create monorepo structure
mkdir -p services/auth services/api services/dashboard
mkdir -p libs/common libs/utils libs/crypto
mkdir -p infrastructure/terraform infrastructure/ansible
mkdir -p docs/api docs/internal
mkdir -p tools/scripts tools/ci

echo '{"name": "auth-service", "version": "1.0.0"}' > services/auth/package.json
echo 'console.log("auth service")' > services/auth/index.js
echo '{"name": "api-service", "version": "2.0.0"}' > services/api/package.json
echo 'console.log("api service")' > services/api/index.js
echo '{"name": "dashboard", "version": "1.5.0"}' > services/dashboard/package.json
echo 'console.log("dashboard")' > services/dashboard/index.js

echo 'module.exports = {helper: () => "common"}' > libs/common/index.js
echo 'module.exports = {format: () => "utils"}' > libs/utils/index.js
echo 'module.exports = {encrypt: () => "crypto"}' > libs/crypto/index.js

echo 'resource "aws_instance" "main" {}' > infrastructure/terraform/main.tf
echo '---' > infrastructure/ansible/playbook.yaml

echo '# API Documentation' > docs/api/README.md
echo '# Internal Docs' > docs/internal/README.md

echo '#!/bin/bash' > tools/scripts/build.sh
echo 'pipeline: true' > tools/ci/config.yaml

echo '# Monorepo' > README.md

git add .
git commit -m "Initial monorepo structure"

# Create working copy with broken sparse checkout
WORK_DIR="$LAB_DIR/workspace"
git clone "$SOURCE_DIR" "$WORK_DIR"
cd "$WORK_DIR"
git config user.email "dev@example.com"
git config user.name "Lab User"

# Set up sparse checkout in cone mode
git sparse-checkout init --cone

# Set to only include services/api and libs/common
git sparse-checkout set services/api libs/common

# Now BREAK the sparse checkout configuration
# 1. Corrupt the sparse-checkout file with invalid patterns
cat > .git/info/sparse-checkout <<'EOF'
/*
!/*/
/services/api/
/libs/common/
/services/auth
!/services/auth/**
**/*.yaml
!**/node_modules/**
EOF

# 2. Disable cone mode but leave cone-mode patterns
git config core.sparseCheckoutCone false

# 3. Add conflicting config
git config core.sparseCheckout true

# This creates a state where:
# - sparse-checkout file has mixed cone/non-cone patterns
# - cone mode is disabled but patterns assume cone mode
# - Some negation patterns conflict with inclusion patterns
# - The checkout shows wrong files

# Force git to re-read the sparse checkout
git read-tree -mu HEAD 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 14: Sparse Checkout Broken"
echo "============================================="
echo ""
echo "📁 Lab directory: $WORK_DIR"
echo ""
echo "SCENARIO:"
echo "  You're working in a monorepo and set up sparse checkout to"
echo "  only pull services/api and libs/common. However, the sparse"
echo "  checkout configuration has been corrupted:"
echo "  - Mixed cone-mode and non-cone patterns in sparse-checkout file"
echo "  - core.sparseCheckoutCone is disabled but patterns need it"
echo "  - Negation patterns are conflicting with include patterns"
echo ""
echo "  You're seeing the wrong files checked out."
echo ""
echo "YOUR TASK:"
echo "  cd $WORK_DIR"
echo "  Fix the sparse checkout so that ONLY these are checked out:"
echo "  - services/api/"
echo "  - libs/common/"
echo "  - README.md"
echo ""
echo "COMMANDS TO START:"
echo "  cd $WORK_DIR"
echo "  ls                           # What files are visible?"
echo "  cat .git/info/sparse-checkout  # See corrupted config"
echo "  git config core.sparseCheckoutCone  # Check cone setting"
echo "  git sparse-checkout list     # See current patterns"
echo ""
