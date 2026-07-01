# Lab 28: Istio Timeout & Retry Misconfiguration

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your microservice architecture has timeout and retry policies configured via Istio VirtualServices. However:
- The `payment-service` times out before retries can complete
- Retries are being attempted for non-retriable error codes (client errors)
- Non-idempotent POST requests to `order-service` are being retried, causing duplicate orders

## Expected Symptoms

- Requests fail even when backend recovers within retry window
- High retry amplification during failures (retry storm)
- 400/401 errors being retried unnecessarily (wasting resources)
- Duplicate order entries in the system
- Premature timeout responses to clients

## Your Task

Diagnose the timeout and retry misconfiguration and fix it according to best practices.

## Hints

<details>
<summary>Hint 1</summary>
Compare the overall `timeout` with the retry budget (attempts × perTryTimeout). The timeout must be greater than or equal to the total retry budget, or retries get cancelled mid-flight.
</details>

<details>
<summary>Hint 2</summary>
Check the `retryOn` conditions. Client errors like 400 (Bad Request) and 401 (Unauthorized) should never be retried — they won't succeed on retry because the request is fundamentally invalid.
</details>

<details>
<summary>Hint 3</summary>
POST requests create new resources. Retrying a POST that failed after partial processing can create duplicate records. Only idempotent methods (GET, PUT, DELETE) should be retried.
</details>

## Useful Commands

```bash
# Check VirtualService timeout and retry config
kubectl get virtualservice -n lab-28-timeout -o yaml

# Check proxy retry settings
istioctl proxy-config routes deploy/order-service -n lab-28-timeout -o json | jq '.[].virtualHosts[].routes[].route.retryPolicy'

# Monitor request stats
kubectl exec deploy/order-service -n lab-28-timeout -c istio-proxy -- pilot-agent request GET stats | grep retry

# Analyze
istioctl analyze -n lab-28-timeout

# Check timeout stats
kubectl exec deploy/payment-service -n lab-28-timeout -c istio-proxy -- pilot-agent request GET stats | grep timeout
```
