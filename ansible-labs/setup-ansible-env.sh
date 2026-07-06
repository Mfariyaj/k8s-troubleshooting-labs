#!/bin/bash
# ============================================================
# Ansible Practice Labs - Environment Setup
# ============================================================
# This script:
# 1. Installs Ansible (if not installed)
# 2. Installs Docker & Docker Compose (if not installed)
# 3. Builds and starts SSH target containers (node1, node2, node3)
# 4. Generates SSH keys and distributes to containers
# 5. Creates master inventory file
# 6. Tests connectivity
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY_PATH="$SCRIPT_DIR/ansible_lab_key"
INVENTORY_PATH="$SCRIPT_DIR/inventory/hosts.ini"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# ============================================================
# STEP 1: Install Ansible
# ============================================================
install_ansible() {
    print_header "Step 1: Installing Ansible"

    if command -v ansible &> /dev/null; then
        ANSIBLE_VERSION=$(ansible --version | head -1)
        print_success "Ansible already installed: $ANSIBLE_VERSION"
        return 0
    fi

    echo "Installing Ansible..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq software-properties-common
        sudo apt-add-repository -y --update ppa:ansible/ansible 2>/dev/null || true
        sudo apt-get install -y -qq ansible python3-pip sshpass
    elif command -v yum &> /dev/null; then
        sudo yum install -y epel-release
        sudo yum install -y ansible python3-pip sshpass
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y ansible python3-pip sshpass
    else
        echo "Installing via pip..."
        pip3 install ansible
        sudo apt-get install -y sshpass 2>/dev/null || sudo yum install -y sshpass 2>/dev/null || true
    fi

    if command -v ansible &> /dev/null; then
        print_success "Ansible installed: $(ansible --version | head -1)"
    else
        print_error "Failed to install Ansible. Please install manually:"
        echo "  pip3 install ansible"
        exit 1
    fi
}

# ============================================================
# STEP 2: Check Docker
# ============================================================
check_docker() {
    print_header "Step 2: Checking Docker"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        echo ""
        echo "Install Docker:"
        echo "  curl -fsSL https://get.docker.com | sh"
        echo "  sudo usermod -aG docker \$USER"
        echo "  newgrp docker"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker daemon not running or permission denied"
        echo "Try: sudo systemctl start docker"
        echo "  or: sudo usermod -aG docker \$USER && newgrp docker"
        exit 1
    fi

    print_success "Docker is running: $(docker --version)"

    # Check docker-compose
    if command -v docker-compose &> /dev/null; then
        print_success "docker-compose available: $(docker-compose --version)"
    elif docker compose version &> /dev/null; then
        print_success "docker compose (plugin) available: $(docker compose version)"
    else
        print_warning "Installing docker-compose..."
        sudo apt-get install -y docker-compose 2>/dev/null || \
            pip3 install docker-compose 2>/dev/null || \
            print_error "Please install docker-compose manually"
    fi
}

# ============================================================
# STEP 3: Generate SSH Keys
# ============================================================
generate_ssh_keys() {
    print_header "Step 3: Generating SSH Keys"

    if [ -f "$SSH_KEY_PATH" ]; then
        print_warning "SSH key already exists: $SSH_KEY_PATH"
        echo "  Remove and regenerate? (y/n)"
        read -r response
        if [ "$response" = "y" ]; then
            rm -f "$SSH_KEY_PATH" "${SSH_KEY_PATH}.pub"
        else
            print_success "Using existing SSH key"
            return 0
        fi
    fi

    ssh-keygen -t rsa -b 2048 -f "$SSH_KEY_PATH" -N "" -q
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "${SSH_KEY_PATH}.pub"

    print_success "SSH key generated: $SSH_KEY_PATH"
}

# ============================================================
# STEP 4: Build and Start Containers
# ============================================================
start_containers() {
    print_header "Step 4: Building and Starting Target Containers"

    cd "$SCRIPT_DIR"

    # Use docker compose (plugin) or docker-compose
    if docker compose version &> /dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi

    echo "Building target container image..."
    $COMPOSE_CMD build --quiet

    echo "Starting containers..."
    $COMPOSE_CMD up -d

    echo ""
    echo "Waiting for SSH to be ready..."
    sleep 3

    # Verify containers are running
    for node in ansible-node1 ansible-node2 ansible-node3; do
        if docker ps --format '{{.Names}}' | grep -q "$node"; then
            print_success "$node is running"
        else
            print_error "$node failed to start"
        fi
    done
}

# ============================================================
# STEP 5: Distribute SSH Keys
# ============================================================
distribute_keys() {
    print_header "Step 5: Distributing SSH Keys to Containers"

    PUB_KEY=$(cat "${SSH_KEY_PATH}.pub")

    for port in 2201 2202 2203; do
        echo "Copying key to localhost:$port..."
        
        # Copy to ansible user
        sshpass -p "ansible123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            -p "$port" ansible@localhost \
            "mkdir -p ~/.ssh && echo '$PUB_KEY' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
            2>/dev/null

        # Copy to deployer user
        sshpass -p "deployer123" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            -p "$port" deployer@localhost \
            "mkdir -p ~/.ssh && echo '$PUB_KEY' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
            2>/dev/null

        print_success "Keys distributed to port $port (ansible + deployer users)"
    done
}

# ============================================================
# STEP 6: Create Inventory Files
# ============================================================
create_inventory() {
    print_header "Step 6: Creating Inventory Files"

    mkdir -p "$SCRIPT_DIR/inventory"

    cat > "$INVENTORY_PATH" << 'EOF'
# ============================================================
# Ansible Practice Labs - Master Inventory
# ============================================================
# Targets: Docker containers with SSH (password + key auth)
# Users: ansible (password: ansible123), deployer (password: deployer123)
# SSH Key: ../ansible_lab_key
# ============================================================

[webservers]
node1 ansible_host=localhost ansible_port=2201

[appservers]
node2 ansible_host=localhost ansible_port=2202

[dbservers]
node3 ansible_host=localhost ansible_port=2203

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=../ansible_lab_key
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[webservers:vars]
server_role=web

[appservers:vars]
server_role=app

[dbservers:vars]
server_role=database
EOF

    # Also create a simplified all-nodes inventory
    cat > "$SCRIPT_DIR/inventory/all-nodes.ini" << 'EOF'
# Simple inventory - all 3 nodes
[targets]
node1 ansible_host=localhost ansible_port=2201
node2 ansible_host=localhost ansible_port=2202
node3 ansible_host=localhost ansible_port=2203

[targets:vars]
ansible_user=ansible
ansible_ssh_private_key_file=../ansible_lab_key
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

    print_success "Created: $INVENTORY_PATH"
    print_success "Created: $SCRIPT_DIR/inventory/all-nodes.ini"
}

# ============================================================
# STEP 7: Create ansible.cfg
# ============================================================
create_ansible_cfg() {
    print_header "Step 7: Creating ansible.cfg"

    cat > "$SCRIPT_DIR/ansible.cfg" << 'EOF'
[defaults]
inventory = inventory/hosts.ini
remote_user = ansible
private_key_file = ansible_lab_key
host_key_checking = False
retry_files_enabled = False
timeout = 30
stdout_callback = yaml
deprecation_warnings = False

[privilege_escalation]
become = False
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
pipelining = True
EOF

    print_success "Created: $SCRIPT_DIR/ansible.cfg"
}

# ============================================================
# STEP 8: Test Connectivity
# ============================================================
test_connectivity() {
    print_header "Step 8: Testing Connectivity"

    cd "$SCRIPT_DIR"

    echo "Testing SSH connection to all nodes..."
    echo ""

    # Test with ansible ping module
    if ansible all -i inventory/hosts.ini -m ping 2>/dev/null; then
        echo ""
        print_success "All nodes are reachable! ✓"
    else
        echo ""
        print_warning "Some nodes may not be reachable yet. Wait a few seconds and try:"
        echo "  cd $SCRIPT_DIR"
        echo "  ansible all -m ping"
    fi

    echo ""
    echo "Testing SSH connection manually..."
    for port in 2201 2202 2203; do
        if ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            -p "$port" ansible@localhost "hostname" 2>/dev/null; then
            print_success "SSH to port $port works"
        else
            print_warning "SSH to port $port - may need more time"
        fi
    done
}

# ============================================================
# STEP 9: Print Summary
# ============================================================
print_summary() {
    print_header "🎉 Setup Complete!"

    echo -e "${GREEN}Your Ansible practice environment is ready!${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│  ENVIRONMENT DETAILS                                         │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "│                                                             │"
    echo "│  Nodes:                                                     │"
    echo "│    node1 (webserver)  → localhost:2201  (172.20.0.11)       │"
    echo "│    node2 (appserver)  → localhost:2202  (172.20.0.12)       │"
    echo "│    node3 (dbserver)   → localhost:2203  (172.20.0.13)       │"
    echo "│                                                             │"
    echo "│  Users:                                                     │"
    echo "│    ansible   (password: ansible123)   - sudo enabled        │"
    echo "│    deployer  (password: deployer123)  - sudo enabled        │"
    echo "│    root      (password: root123)                            │"
    echo "│                                                             │"
    echo "│  SSH Key: $SSH_KEY_PATH"
    echo "│  Inventory: $INVENTORY_PATH"
    echo "│                                                             │"
    echo "│  Quick Test:                                                │"
    echo "│    cd $SCRIPT_DIR"
    echo "│    ansible all -m ping                                      │"
    echo "│    ansible all -m shell -a 'uptime'                         │"
    echo "│                                                             │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
    echo -e "${YELLOW}To start a lab:${NC}"
    echo "  cd lab-01-ssh-connection-failure"
    echo "  cat README.md"
    echo "  ./deploy.sh"
    echo ""
    echo -e "${YELLOW}To stop the environment:${NC}"
    echo "  cd $SCRIPT_DIR && docker-compose down"
    echo ""
    echo -e "${YELLOW}To restart the environment:${NC}"
    echo "  cd $SCRIPT_DIR && docker-compose up -d"
    echo ""
}

# ============================================================
# MAIN
# ============================================================
main() {
    print_header "🚀 Ansible Practice Labs - Environment Setup"
    echo "This will set up Docker-based SSH target containers"
    echo "for practicing Ansible labs locally."
    echo ""

    install_ansible
    check_docker
    generate_ssh_keys
    start_containers
    distribute_keys
    create_inventory
    create_ansible_cfg
    test_connectivity
    print_summary
}

main "$@"
