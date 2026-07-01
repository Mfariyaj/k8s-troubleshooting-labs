# Lab 25: Istio Circuit Breaker Not Tripping

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your `payment-service` has some unhealthy pods that return 5xx errors. You've configured Istio's circuit breaker (outlier detection) to eject failing pods from the load balancing pool. However, traffic continues to be sent to the unhealthy pods, causing cascading failures and degraded user experience.

## Expected Symptoms

- Unhealthy pods continue receiving traffic despite returning errors
- High 5xx error rate not decreasing over time
- `istioctl proxy-config clusters` shows no ejected hosts
- Circuit breaker metrics show no ejections happening
- The outlier detection appears configured but never triggers

## Your Task

Diagnose why the circuit breaker isn't tripping and fix the outlier detection configuration.

## Hints

<details>
<summary>Hint 1</summary>
Look at the `consecutive5xxErrors` threshold. If it's unrealistically high, the circuit breaker will never trip under normal error conditions.
</details>

<details>
<summary>Hint 2</summary>
Check the `interval` and `baseEjectionTime`. If the check interval is too long, detection is delayed. If the ejection time is too short, the host comes back immediately.
</details>

<details>
<summary>Hint 3</summary>
The `maxEjectionPercent` controls what percentage of hosts can be ejected from the pool. If set to 0, no hosts will ever be ejected regardless of other settings.
</details>

## Useful Commands

```bash
# Check DestinationRule outlierDetection config
kubectl get destinationrule -n lab-25-circuitbreaker -o yaml

# Check proxy cluster health
istioctl proxy-config clusters deploy/payment-client -n lab-25-circuitbreaker | grep payment

# Check endpoints
istioctl proxy-config endpoints deploy/payment-client -n lab-25-circuitbreaker | grep payment

# Generate test traffic
kubectl exec deploy/payment-client -n lab-25-circuitbreaker -- sh -c 'for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code}\n" http://payment-service; done'

# Check Envoy stats for outlier detection
kubectl exec deploy/payment-client -n lab-25-circuitbreaker -c istio-proxy -- pilot-agent request GET stats | grep outlier
```
