#!/bin/bash
set -e

echo "============================================"
echo " WAL Corruption Simulation Script"
echo "============================================"
echo ""
echo "This script simulates an unclean shutdown that corrupts the WAL."
echo ""

CONTAINER="prometheus-wal-corrupt"
DATA_VOLUME="lab-12-wal-corruption_prometheus-data"

# Step 1: Ensure Prometheus is running and has some data
echo "[1/5] Checking Prometheus is running..."
if ! docker ps --format '{{.Names}}' | grep -q "$CONTAINER"; then
    echo "ERROR: Prometheus container not running. Run deploy.sh first."
    exit 1
fi

echo "[2/5] Waiting for Prometheus to accumulate data (30 seconds)..."
echo "       (WAL needs active writes to be corruptible)"
sleep 30

echo "[3/5] Triggering heavy writes to ensure WAL is actively being written..."
# Create a bunch of recording rules to generate write pressure
for i in $(seq 1 100); do
    curl -s "localhost:9090/api/v1/query?query=up" > /dev/null 2>&1
done

echo "[4/5] Killing Prometheus with SIGKILL (no graceful shutdown)..."
echo "       This simulates: power loss, kernel OOM kill, 'kill -9'"
docker kill --signal=SIGKILL "$CONTAINER"
sleep 2

echo "[5/5] Corrupting WAL segments directly..."
# Mount the volume and corrupt WAL files
docker run --rm -v "${DATA_VOLUME}:/prometheus" alpine:3.19 sh -c '
    echo "Current WAL state:"
    ls -la /prometheus/wal/ 2>/dev/null || echo "No WAL directory!"
    
    # Truncate the last WAL segment (simulates partial write during crash)
    LAST_SEGMENT=$(ls /prometheus/wal/ 2>/dev/null | grep -E "^[0-9]+" | sort -n | tail -1)
    if [ -n "$LAST_SEGMENT" ]; then
        echo "Truncating last WAL segment: $LAST_SEGMENT"
        # Write garbage to middle of the segment (partial write simulation)
        FILESIZE=$(stat -c%s "/prometheus/wal/$LAST_SEGMENT")
        MIDPOINT=$((FILESIZE / 2))
        dd if=/dev/urandom of="/prometheus/wal/$LAST_SEGMENT" bs=1 count=4096 seek=$MIDPOINT conv=notrunc 2>/dev/null
        echo "Corrupted $LAST_SEGMENT at offset $MIDPOINT"
    fi
    
    # Remove checkpoint (simulates missing checkpoint after crash)
    rm -rf /prometheus/wal/checkpoint.*
    echo "Removed WAL checkpoints"
    
    # Corrupt a segment header (makes it unreadable)
    FIRST_SEGMENT=$(ls /prometheus/wal/ 2>/dev/null | grep -E "^[0-9]+" | sort -n | head -1)
    if [ -n "$FIRST_SEGMENT" ]; then
        echo "Corrupting segment header: $FIRST_SEGMENT"
        printf "\x00\x00\x00\x00\x00\x00\x00\x00" | dd of="/prometheus/wal/$FIRST_SEGMENT" bs=1 count=8 seek=0 conv=notrunc 2>/dev/null
    fi
    
    echo ""
    echo "WAL corruption complete. Prometheus will fail to start."
    echo "Final WAL state:"
    ls -la /prometheus/wal/
'

echo ""
echo "============================================"
echo " WAL Corruption Complete!"
echo "============================================"
echo ""
echo "Now try to start Prometheus:"
echo "  docker compose up -d prometheus"
echo ""
echo "You should see WAL replay errors in the logs:"
echo "  docker logs prometheus-wal-corrupt"
echo ""
echo "Your task: Recover Prometheus and understand what data was lost."
