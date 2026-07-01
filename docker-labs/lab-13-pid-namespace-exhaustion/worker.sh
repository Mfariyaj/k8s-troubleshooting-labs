#!/bin/bash
# Worker process that forks children aggressively
# BUG 1: Does not reap zombie children (ignores SIGCHLD incorrectly)
# BUG 2: Forks without any limit
# BUG 3: Child processes themselves fork (fork bomb potential)

# BUG: trap '' SIGCHLD ignores child death signals, preventing wait() from reaping
trap '' SIGCHLD

WORKER_ID=${WORKER_ID:-"default"}
MAX_CHILDREN=${MAX_CHILDREN:-500}
CHILD_COUNT=0

echo "[WORKER-$WORKER_ID] Starting worker process (PID: $$)"
echo "[WORKER-$WORKER_ID] Max children configured: $MAX_CHILDREN"
echo "[WORKER-$WORKER_ID] SIGCHLD handler: IGNORED (zombies will accumulate)"

process_task() {
    local task_id=$1
    # Simulate work
    sleep $((RANDOM % 10 + 1))
    
    # BUG: Child process also forks sub-children (grandchildren)
    if [ $((task_id % 5)) -eq 0 ]; then
        for sub in $(seq 1 3); do
            (
                sleep $((RANDOM % 30 + 5))
                # Grandchild exits but parent already exited → reparented to PID 1
                # PID 1 (if not a proper init) won't reap them → zombie
            ) &
        done
    fi
    
    exit 0
}

while true; do
    CHILD_COUNT=$((CHILD_COUNT + 1))
    
    if [ $CHILD_COUNT -gt $MAX_CHILDREN ]; then
        echo "[WORKER-$WORKER_ID] ERROR: Reached max children ($MAX_CHILDREN), still spawning..."
        # BUG: Does NOT wait for children to complete, just keeps forking
        # Should call: wait -n  or  wait
    fi
    
    # Fork a child process for each "task"
    process_task $CHILD_COUNT &
    
    # BUG: No rate limiting on fork
    # BUG: Never calls wait, so zombie processes accumulate
    
    # Minimal sleep (not enough to prevent PID exhaustion)
    sleep 0.05
    
    # Log zombie count periodically
    if [ $((CHILD_COUNT % 100)) -eq 0 ]; then
        ZOMBIE_COUNT=$(ps aux 2>/dev/null | grep -c "[Zz]" || echo "unknown")
        TOTAL_PIDS=$(ls /proc 2>/dev/null | grep -c "^[0-9]" || echo "unknown")
        echo "[WORKER-$WORKER_ID] Status: children_spawned=$CHILD_COUNT zombies=$ZOMBIE_COUNT total_pids=$TOTAL_PIDS"
    fi
done
