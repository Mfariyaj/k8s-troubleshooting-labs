#!/bin/bash
# Disk Analysis Script - Shows the disk exhaustion problem
# Run this after deploying to see how fast disk fills up

echo "============================================="
echo "  Docker Disk Exhaustion Analysis"
echo "============================================="
echo ""

echo "--- Docker System Disk Usage ---"
docker system df
echo ""

echo "--- Docker System Disk Usage (Verbose) ---"
docker system df -v
echo ""

echo "--- overlay2 Layer Count ---"
echo "Total layers: $(ls /var/lib/docker/overlay2/ 2>/dev/null | wc -l)"
echo ""

echo "--- Container Log Sizes ---"
echo "Finding all container logs..."
find /var/lib/docker/containers -name "*-json.log" -exec ls -lh {} \; 2>/dev/null
echo ""

echo "--- Total Log Size ---"
du -sh /var/lib/docker/containers/ 2>/dev/null
echo ""

echo "--- Dangling Images ---"
echo "Count: $(docker images -f dangling=true -q | wc -l)"
docker images -f dangling=true --format "{{.ID}} {{.Size}} {{.CreatedSince}}"
echo ""

echo "--- Exited Containers (Still Consuming Space) ---"
docker ps -a -f status=exited --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Status}}"
echo ""

echo "--- Orphaned Volumes ---"
echo "Count: $(docker volume ls -f dangling=true -q | wc -l)"
docker volume ls -f dangling=true
echo ""

echo "--- Build Cache ---"
docker builder du 2>/dev/null || echo "BuildKit not available for 'docker builder du'"
echo ""

echo "--- Current daemon.json (LOG ROTATION CHECK) ---"
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json
    if ! grep -q "max-size" /etc/docker/daemon.json; then
        echo ""
        echo "[CRITICAL] No log rotation configured in daemon.json!"
        echo "[CRITICAL] Container logs will grow unbounded!"
    fi
else
    echo "[CRITICAL] No /etc/docker/daemon.json found - using defaults (no rotation)!"
fi
echo ""

echo "--- Reclaimable Space Summary ---"
echo "To see what can be reclaimed:"
echo "  docker system prune -a --volumes --dry-run"
echo ""
echo "============================================="
echo "  Analysis Complete"
echo "============================================="
