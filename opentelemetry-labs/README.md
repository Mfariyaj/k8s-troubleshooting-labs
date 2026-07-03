# 🔭 OpenTelemetry Troubleshooting Labs

## 10 Real-World Broken Observability Scenarios

---

## 📚 What is OpenTelemetry?

OpenTelemetry (OTel) is the **industry standard for observability**. It provides ONE unified way to collect:
- **Traces** — Follow requests across microservices
- **Metrics** — Numbers over time (CPU, request count, latency)
- **Logs** — Structured event messages

### Why It's Replacing Everything:
- Before OTel: Datadog SDK + Prometheus client + Jaeger client = 3 SDKs
- After OTel: ONE SDK → export to ANY backend

---

## 🏗️ Architecture

```
┌────────────┐    ┌────────────┐    ┌────────────┐
│  Service A │    │  Service B │    │  Service C │
│  (OTel SDK)│    │  (OTel SDK)│    │  (OTel SDK)│
└─────┬──────┘    └─────┬──────┘    └─────┬──────┘
      │                  │                  │
      │    OTLP (gRPC :4317 / HTTP :4318)   │
      ▼                  ▼                  ▼
┌─────────────────────────────────────────────────┐
│              OTel Collector                       │
│                                                  │
│  Receivers → Processors → Exporters             │
│  (OTLP)     (batch,       (Prometheus,          │
│              filter,        Jaeger,              │
│              sampling)      Tempo,              │
│                             Datadog)            │
└─────────────────────────────────────────────────┘
      │              │              │
      ▼              ▼              ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│Prometheus│  │  Jaeger  │  │  Grafana │
│(metrics) │  │ (traces) │  │  (viz)   │
└──────────┘  └──────────┘  └──────────┘
```

---

## 🔑 Key Concepts

### The 3 Signals:
| Signal | What | Example | Tool |
|--------|------|---------|------|
| **Trace** | Request journey across services | User→API→DB→Cache | Jaeger, Tempo |
| **Metric** | Number measurement over time | CPU=85%, 100 req/s | Prometheus |
| **Log** | Event message with context | "Error: DB timeout" | Loki, ELK |

### Collector Pipeline:
```yaml
receivers:     # HOW data comes in
  otlp:        # Standard OTel protocol
    protocols:
      grpc: { endpoint: 0.0.0.0:4317 }
      http: { endpoint: 0.0.0.0:4318 }

processors:    # WHAT to do with data
  batch:       # Batch for efficiency
    timeout: 5s
  filter:      # Drop unwanted data
  tail_sampling:  # Smart sampling

exporters:     # WHERE to send data
  prometheus: { endpoint: 0.0.0.0:8889 }
  otlp: { endpoint: tempo:4317 }

service:       # Wire it together
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
```

---

## 📋 Labs

| # | Lab | Difficulty | What You'll Learn |
|---|-----|-----------|-------------------|
| 01 | Collector Not Receiving | ⭐ Easy | Receiver config, ports, protocols |
| 02 | Exporter Connection Failed | ⭐⭐ Medium | Backend connectivity, auth |
| 03 | Sampling Dropping All | ⭐⭐ Medium | Sampling policies, tail vs head |
| 04 | Context Propagation Broken | ⭐⭐⭐ Hard | W3C TraceContext, headers |
| 05 | Metrics Pipeline Broken | ⭐⭐ Medium | Processor queues, backpressure |
| 06 | Resource Attributes Missing | ⭐ Easy | service.name, deployment.env |
| 07 | Batch Processor Timeout | ⭐⭐ Medium | Timeout vs size, data loss |
| 08 | TLS Certificate Error | ⭐⭐⭐ Hard | mTLS between components |
| 09 | Log Pipeline Parsing | ⭐⭐ Medium | Regex operators, structured logs |
| 10 | K8s Operator Crashing | ⭐⭐⭐ Hard | OTelCollector CRD, pod config |

---

## 📖 Reference
- Docs: https://opentelemetry.io/docs/
- Collector: https://opentelemetry.io/docs/collector/
- SDK: https://opentelemetry.io/docs/instrumentation/
