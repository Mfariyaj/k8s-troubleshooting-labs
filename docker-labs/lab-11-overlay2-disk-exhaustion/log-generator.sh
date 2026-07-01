#!/bin/bash
# Simulates a production service that generates excessive logging
# This mimics a misconfigured application with DEBUG level logging in production

SERVICE_NAME="payment-service"
COUNTER=0

echo "[INFO] $SERVICE_NAME starting up..."
echo "[INFO] Log rotation: NONE (json-file driver, no max-size configured)"
echo "[WARN] This service will generate ~10MB of logs per minute"

while true; do
    COUNTER=$((COUNTER + 1))
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    # Generate verbose debug logging (the bug - DEBUG in production)
    echo "[$TIMESTAMP] [DEBUG] [$SERVICE_NAME] Processing transaction #$COUNTER - Request received from gateway"
    echo "[$TIMESTAMP] [DEBUG] [$SERVICE_NAME] Transaction #$COUNTER - Validating payment token: tok_$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 32)"
    echo "[$TIMESTAMP] [DEBUG] [$SERVICE_NAME] Transaction #$COUNTER - Database query: SELECT * FROM transactions WHERE id=$COUNTER AND status='pending' ORDER BY created_at DESC LIMIT 100"
    echo "[$TIMESTAMP] [DEBUG] [$SERVICE_NAME] Transaction #$COUNTER - Response payload: {\"id\":$COUNTER,\"status\":\"processed\",\"amount\":$(shuf -i 100-99999 -n 1),\"currency\":\"USD\",\"metadata\":{\"trace_id\":\"$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 16)\",\"span_id\":\"$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 8)\"}}"
    echo "[$TIMESTAMP] [INFO] [$SERVICE_NAME] Transaction #$COUNTER completed successfully" >&2
    
    # Every 100th iteration, dump a "stack trace" to stderr
    if [ $((COUNTER % 100)) -eq 0 ]; then
        echo "[$TIMESTAMP] [WARN] [$SERVICE_NAME] Slow query detected (${COUNTER}ms)" >&2
        echo "[$TIMESTAMP] [WARN] [$SERVICE_NAME]   at com.payment.service.TransactionHandler.process(TransactionHandler.java:142)" >&2
        echo "[$TIMESTAMP] [WARN] [$SERVICE_NAME]   at com.payment.service.Gateway.handle(Gateway.java:89)" >&2
        echo "[$TIMESTAMP] [WARN] [$SERVICE_NAME]   at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:379)" >&2
    fi
    
    # Minimal sleep to simulate high-throughput service
    sleep 0.01
done
