## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 05: Canary Analysis Failure — Kayenta Always Reports Failure

## Difficulty: 🔴 Advanced

---

## 📚 What You'll Learn

**Automated Canary Analysis (ACA)** is one of Spinnaker's most powerful features. It uses **Kayenta** to statistically compare metrics between a canary deployment and a baseline deployment.

How it works:
1. Spinnaker deploys a canary (new version) alongside a baseline (current version)
2. Both receive a small percentage of traffic
3. Kayenta queries a metric store (Prometheus, Datadog, Stackdriver, New Relic)
4. It compares metrics using the Mann-Whitney U test or other statistical methods
5. Each metric gets a score: Pass, High, Low, or Nodata
6. Overall canary score is calculated (0-100)
7. If score exceeds the threshold (e.g., 75), canary passes

Key components:
- **Canary Config**: Defines which metrics to compare, thresholds, and scoring
- **Metric Store**: Where metrics come from (Prometheus, Datadog, etc.)
- **Canary Scope**: Defines how to filter metrics for canary vs baseline
- **Scoring**: Marginal threshold (50-74), Pass threshold (75+), weights per metric group

Common failure reasons:
- Metric queries return empty/null for canary or baseline
- Thresholds set impossibly strict (100% required)
- Wrong metric source account name
- Scope selectors don't match actual metric labels

---

## 🔧 Scenario

A canary pipeline is configured but ACA always reports failure, even when the canary is perfectly healthy. The issues are:

1. The canary config references a metrics account `my-prometheus` that's named `prometheus-prod` in the actual config
2. The metric query filter uses `pod_name` label but Prometheus uses `pod` (changed in newer K8s versions)
3. The pass threshold is set to 100 (impossible — statistical tests have inherent variance)

---

## 💥 Expected Error Output

In Spinnaker UI (Canary Report):
```
Canary Analysis Results:
  Overall Score: 0 / 100  ❌ FAILED
  
  Metric Group "Performance":
    - request_latency_p99: NODATA
      Reason: No data points returned for canary scope
    - error_rate: NODATA  
      Reason: Metric query returned null for both canary and baseline
  
  Metric Group "Resource Usage":
    - cpu_utilization: HIGH (score: 60)
      Reason: Canary mean (0.45) significantly higher than baseline (0.42)

Kayenta logs:
  ERROR c.n.k.metrics.PrometheusMetricsService - 
    Failed to query metrics account 'my-prometheus': 
    Account not found. Available accounts: [prometheus-prod]
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check the canary config's `metricsAccountName`. Does it match what's configured in Kayenta? Run `hal config canary prometheus account list` to see configured accounts.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Look at the metric queries. Prometheus deprecated `pod_name` in favor of `pod` starting with Kubernetes 1.16+. The query filter `{pod_name=~"myapp-canary.*"}` won't match anything.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change `metricsAccountName` from `my-prometheus` to `prometheus-prod`, 2) Change `pod_name` to `pod` in all metric queries, 3) Lower the pass threshold from 100 to 75 (standard recommended value).
</details>

---

## 🛠️ Useful Commands

```bash
# Check Kayenta configuration
hal config canary prometheus account list
hal config canary edit --show

# View canary configs via API
curl http://localhost:8084/v2/canaries/canaryConfig | jq .

# Check Kayenta pod logs
kubectl logs -n spinnaker spin-kayenta-xxx | grep -i "error\|account"

# Query Prometheus directly to verify metric availability
kubectl port-forward -n monitoring svc/prometheus 9090:9090
curl 'http://localhost:9090/api/v1/query?query=request_latency_seconds{pod=~"myapp.*"}'

# List available metric accounts
curl http://localhost:8084/credentials?expand=true | jq '.[] | select(.type == "metrics_store")'
```

---

## 📖 References

- https://spinnaker.io/docs/guides/user/canary/
- https://spinnaker.io/docs/guides/user/canary/config/
- https://spinnaker.io/docs/guides/user/canary/stage/
- https://spinnaker.io/docs/setup/canary/

---

## 🏁 Success Criteria

- Kayenta successfully queries metrics for both canary and baseline
- No NODATA results for metrics
- Canary score reflects actual performance difference (not 0)
- Pipeline passes when canary is healthy (score above threshold)
