#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up lab-13-pid-namespace-exhaustion..."
echo "[!] Stopping aggressive forkers first..."

cd "$LAB_DIR"

# Force stop all containers (they may be stuck)
docker compose kill 2>/dev/null || true
docker compose down -v 2>/dev/null || true

# Force remove if still present
docker rm -f worker-alpha worker-beta worker-gamma api-server 2>/dev/null || true

# Clean up any remaining zombie processes from this lab
# (zombies with host PID namespace will need parent to reap them)
echo "[!] Note: Host zombies can only be cleaned by killing their parent or rebooting"

echo "Lab 13 cleaned up."
echo "If zombies persist on the host, their parent processes need to be terminated."
