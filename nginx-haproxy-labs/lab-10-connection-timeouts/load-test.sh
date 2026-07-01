#!/bin/bash
# Load test script for Lab 10 - Connection Timeouts

echo "🔥 Running load test against http://localhost:8091/"
echo "=================================================="
echo ""

# Check if ab (Apache Bench) is available
if command -v ab &> /dev/null; then
    echo "📊 Using Apache Bench (ab)..."
    echo ""
    echo "--- Test 1: 50 concurrent requests to fast endpoint ---"
    ab -n 100 -c 50 http://localhost:8091/ 2>&1 | grep -E "(Complete requests|Failed requests|Time taken|Requests per second|Connection Times)"
    echo ""
    echo "--- Test 2: 20 concurrent requests to slow endpoint ---"
    ab -n 20 -c 20 http://localhost:8091/slow 2>&1 | grep -E "(Complete requests|Failed requests|Time taken|Requests per second|Connection Times)"
else
    echo "📊 Using curl (ab not available)..."
    echo ""
    echo "--- Sending 20 concurrent requests ---"
    echo ""

    # Send concurrent requests using background curl processes
    PASS=0
    FAIL=0

    for i in $(seq 1 20); do
        curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost:8091/medium &
    done

    # Wait for all background jobs
    echo "Waiting for all requests to complete..."
    RESULTS=""
    for job in $(jobs -p); do
        wait $job
        STATUS=$?
        if [ $STATUS -eq 0 ]; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
    done

    echo ""
    echo "Results: $PASS succeeded, $FAIL failed"
    echo ""

    echo "--- Sequential timing test ---"
    for i in 1 2 3 4 5; do
        TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 10 http://localhost:8091/slow)
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://localhost:8091/)
        echo "Request $i: Status=$STATUS, Time=${TIME}s"
    done
fi

echo ""
echo "=================================================="
echo "📋 With worker_connections=10 and keepalive_timeout=0,"
echo "   Nginx cannot handle concurrent connections and requests fail/timeout."
echo ""
echo "🔍 Check error logs:"
echo "   docker exec lab-10-connection-timeouts-nginx-1 cat /var/log/nginx/error.log"
