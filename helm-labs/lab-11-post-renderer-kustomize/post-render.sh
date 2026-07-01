#!/bin/bash
# Post-renderer script for Kustomize integration
# This script reads Helm output from stdin and applies Kustomize patches

KUSTOMIZE_DIR="$(dirname $0)/kustomize"

# BUG 1: Using absolute path that doesn't exist on most systems
KUSTOMIZE_BIN="/usr/local/bin/kustomize"

# BUG 2: Not reading stdin properly - writing to wrong file
# BUG 3: Using 'cat' to write but not capturing stdin first
cat > $KUSTOMIZE_DIR/rendered.yaml

# BUG 4: Running kustomize on wrong directory and not outputting to stdout
$KUSTOMIZE_BIN build $KUSTOMIZE_DIR > /tmp/kustomize-output.yaml

# BUG 5: Output goes to file instead of stdout (post-renderer MUST write to stdout)
cat /tmp/kustomize-output.yaml
exit 0
