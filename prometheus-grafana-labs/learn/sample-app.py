#!/usr/bin/env python3
"""
Sample App - Exposes Prometheus Metrics
========================================
This app demonstrates how applications expose metrics for Prometheus.

Metrics exposed:
  - app_requests_total (Counter): Total HTTP requests by status
  - app_request_duration_seconds (Histogram): Request latency
  - app_active_users (Gauge): Current active users (goes up and down)
"""

from prometheus_client import Counter, Histogram, Gauge, generate_latest
from flask import Flask, Response
import random
import threading
import time

app = Flask(__name__)

# =============================================================================
# METRICS DEFINITIONS
# =============================================================================

# Counter: only goes UP (total requests, total errors)
REQUEST_COUNT = Counter(
    'app_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']  # Labels for filtering
)

# Histogram: measures distribution (latency percentiles)
REQUEST_DURATION = Histogram(
    'app_request_duration_seconds',
    'Request duration in seconds',
    ['endpoint'],
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]
)

# Gauge: goes UP and DOWN (active connections, queue size)
ACTIVE_USERS = Gauge(
    'app_active_users',
    'Number of currently active users'
)

# =============================================================================
# SIMULATE TRAFFIC (generates fake metrics)
# =============================================================================

def simulate_traffic():
    """Background thread that simulates app traffic"""
    while True:
        # Simulate requests
        endpoint = random.choice(['/api/users', '/api/orders', '/api/products', '/health'])
        method = random.choice(['GET', 'GET', 'GET', 'POST'])
        status = random.choice(['success', 'success', 'success', 'success', 'error'])  # 20% errors

        # Record metrics
        REQUEST_COUNT.labels(method=method, endpoint=endpoint, status=status).inc()

        duration = random.uniform(0.01, 0.5) if status == 'success' else random.uniform(0.5, 3.0)
        REQUEST_DURATION.labels(endpoint=endpoint).observe(duration)

        # Fluctuate active users
        ACTIVE_USERS.set(random.randint(10, 100))

        time.sleep(random.uniform(0.5, 2.0))

# Start background traffic
threading.Thread(target=simulate_traffic, daemon=True).start()

# =============================================================================
# ENDPOINTS
# =============================================================================

@app.route('/')
def home():
    return "Sample App - Metrics at /metrics"

@app.route('/metrics')
def metrics():
    """Prometheus scrapes this endpoint to collect metrics"""
    return Response(generate_latest(), mimetype='text/plain')

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    print("🚀 Sample app running on http://0.0.0.0:8000")
    print("📊 Metrics at http://0.0.0.0:8000/metrics")
    app.run(host='0.0.0.0', port=8000)
