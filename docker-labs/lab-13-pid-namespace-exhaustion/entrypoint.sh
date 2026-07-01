#!/bin/bash
# Entrypoint that runs as PID 1
# BUG: Bash as PID 1 does NOT automatically reap zombie children
# BUG: No signal forwarding to child processes

echo "[ENTRYPOINT] Starting as PID $$"
echo "[ENTRYPOINT] Running as PID 1: $([ $$ -eq 1 ] && echo 'YES (no init system!)' || echo 'NO')"
echo "[ENTRYPOINT] Kernel PID max: $(cat /proc/sys/kernel/pid_max 2>/dev/null || echo 'unknown')"
echo "[ENTRYPOINT] Container pids.max: $(cat /sys/fs/cgroup/pids.max 2>/dev/null || cat /sys/fs/cgroup/pids/pids.max 2>/dev/null || echo 'unknown')"

# BUG: exec replaces this shell, worker.sh becomes PID 1
# worker.sh is bash and does NOT reap zombies properly
exec /app/worker.sh
