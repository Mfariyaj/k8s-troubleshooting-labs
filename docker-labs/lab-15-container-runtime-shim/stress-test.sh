#!/bin/bash
# Stress test that causes memory pressure leading to shim OOM
# Different allocation patterns based on environment configuration

ALLOC_MB=${ALLOC_MB:-200}
ALLOC_PATTERN=${ALLOC_PATTERN:-gradual}

echo "[STRESS] Container starting"
echo "[STRESS] PID: $$"
echo "[STRESS] Target allocation: ${ALLOC_MB}MB"
echo "[STRESS] Pattern: $ALLOC_PATTERN"
echo "[STRESS] Container memory limit: $(cat /sys/fs/cgroup/memory.max 2>/dev/null || cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null || echo 'unknown')"
echo ""

case "$ALLOC_PATTERN" in
    gradual)
        # Gradually increase memory until OOM
        echo "[STRESS] Gradual allocation - increasing 10MB every 5 seconds"
        CURRENT=0
        while [ $CURRENT -lt $ALLOC_MB ]; do
            CURRENT=$((CURRENT + 10))
            echo "[STRESS] Allocating ${CURRENT}MB / ${ALLOC_MB}MB target..."
            # Use python to allocate memory and hold it
            python3 -c "
import time
data = []
try:
    data.append(bytearray($CURRENT * 1024 * 1024))
    time.sleep(5)
except MemoryError:
    print('[STRESS] MemoryError at ${CURRENT}MB - approaching OOM')
    time.sleep(5)
" 2>/dev/null || true
        done
        ;;
    burst)
        # Allocate all at once
        echo "[STRESS] Burst allocation - allocating ${ALLOC_MB}MB immediately"
        python3 -c "
import time, sys
try:
    data = bytearray($ALLOC_MB * 1024 * 1024)
    print(f'[STRESS] Allocated {len(data)} bytes successfully')
    while True:
        time.sleep(1)
except MemoryError:
    print('[STRESS] MemoryError - OOM imminent', file=sys.stderr)
    time.sleep(60)
" 2>/dev/null || true
        ;;
    random)
        # Random allocations with fragmentation
        echo "[STRESS] Random allocation with memory fragmentation"
        python3 -c "
import time, random, sys
chunks = []
total = 0
target = $ALLOC_MB * 1024 * 1024
try:
    while total < target:
        size = random.randint(1024 * 1024, 20 * 1024 * 1024)  # 1-20MB chunks
        chunks.append(bytearray(size))
        total += size
        print(f'[STRESS] Total allocated: {total // (1024*1024)}MB / {$ALLOC_MB}MB')
        time.sleep(random.uniform(0.5, 2.0))
except MemoryError:
    print(f'[STRESS] MemoryError at {total // (1024*1024)}MB', file=sys.stderr)
    while True:
        time.sleep(1)
" 2>/dev/null || true
        ;;
esac

# If we get here, something recovered — keep running
echo "[STRESS] Allocation phase complete, entering idle loop"
while true; do
    echo "[STRESS] Heartbeat - $(date -u +%Y-%m-%dT%H:%M:%SZ) - RSS: $(ps -o rss= -p $$ 2>/dev/null || echo 'unknown')KB"
    sleep 10
done
