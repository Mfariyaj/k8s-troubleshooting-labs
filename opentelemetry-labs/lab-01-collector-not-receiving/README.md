## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh`
2. Observe the error output
3. Diagnose the root cause
4. Apply the fix
5. Verify it works. Check `solution.md` if stuck

---

# OTel Collector Not Receiving Data

## Difficulty: ⭐⭐ Medium

## 📚 What This Teaches
The OpenTelemetry Collector is running but not receiving any traces/metrics. Receiver endpoint misconfigured, wrong port, or protocol mismatch.

## 🔧 Scenario
The OpenTelemetry Collector is running but not receiving any traces/metrics. Receiver endpoint misconfigured, wrong port, or protocol mismatch.

## 💥 Error Output
```
2024-01-15T10:30:00.000Z warn receiver/otlp: No data received in the last 60 seconds
2024-01-15T10:30:01.000Z error exporterhelper: data dropped: no data to export
```

## 💡 Hints

<details><summary>Hint 1</summary>
Check collector config: what port is the receiver listening on? (default: gRPC=4317, HTTP=4318)
</details>

<details><summary>Hint 2</summary>
Check if the app SDK is sending to the same port/protocol. OTLP gRPC != OTLP HTTP!
</details>

<details><summary>Hint 3</summary>
Ensure receiver endpoint matches what apps send to. Check: grpc://localhost:4317 vs http://localhost:4318. Also check the collector is actually running.
</details>

## 🛠️ Useful Commands
```bash
docker logs otel-collector 2>&1 | grep -i 'listen\|error\|receiver'
curl -v http://localhost:4318/v1/traces  # Test HTTP receiver
grpcurl -plaintext localhost:4317 list   # Test gRPC receiver
cat otel-collector-config.yaml | grep -A5 receivers
```
