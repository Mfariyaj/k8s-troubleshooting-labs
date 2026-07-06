#!/bin/bash
# ============================================================
# Ansible Labs - Common Helper Functions
# ============================================================
# Source this in deploy.sh scripts: source ../lab-helper.sh
# ============================================================

LABS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_environment() {
    # Check if Docker containers are running
    local nodes_running=0
    for node in ansible-node1 ansible-node2 ansible-node3; do
        if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "$node"; then
            nodes_running=$((nodes_running + 1))
        fi
    done

    if [ "$nodes_running" -eq 0 ]; then
        echo -e "${RED}============================================${NC}"
        echo -e "${RED}  ERROR: Ansible target containers not running!${NC}"
        echo -e "${RED}============================================${NC}"
        echo ""
        echo "Please run the environment setup first:"
        echo "  cd $LABS_DIR"
        echo "  bash setup-ansible-env.sh"
        echo ""
        echo "Or start containers manually:"
        echo "  cd $LABS_DIR && docker-compose up -d"
        echo ""
        exit 1
    fi

    echo -e "${GREEN}✓ $nodes_running/3 target nodes running${NC}"
}

print_lab_header() {
    local lab_name="$1"
    local description="$2"
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  $lab_name${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    if [ -n "$description" ]; then
        echo -e "${YELLOW}Scenario:${NC} $description"
        echo ""
    fi
}

print_lab_footer() {
    echo ""
    echo -e "${YELLOW}============================================${NC}"
    echo -e "${YELLOW}  YOUR TASK: Diagnose and fix the issue!${NC}"
    echo -e "${YELLOW}============================================${NC}"
    echo ""
    echo "Helpful commands:"
    echo "  cat README.md              # Read the scenario"
    echo "  cat playbook.yml           # Examine the playbook"
    echo "  cat inventory.ini          # Check inventory"
    echo "  ansible-playbook ...       # Re-run after fixing"
    echo "  cat solution.md            # If you're stuck"
    echo ""
}
