## Solution: OTel Collector Not Receiving Data

### Root Cause
The OpenTelemetry Collector is running but not receiving any traces/metrics. Receiver endpoint misconfigured, wrong port, or protocol mismatch.

### Fix
Ensure receiver endpoint matches what apps send to. Check: grpc://localhost:4317 vs http://localhost:4318. Also check the collector is actually running.

### Verification
Run the commands below to verify the fix works:
```bash
docker logs otel-collector 2>&1 | grep -i 'listen\|error\|receiver'
curl -v http://localhost:4318/v1/traces  # Test HTTP receiver
grpcurl -plaintext localhost:4317 list   # Test gRPC receiver
cat otel-collector-config.yaml | grep -A5 receivers
```
