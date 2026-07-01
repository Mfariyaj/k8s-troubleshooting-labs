#!/usr/bin/env python3
"""
High-cardinality metrics server.
Simulates an application that exposes unbounded label values.
This will cause Prometheus to OOM due to millions of unique time series.
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import random
import string
import uuid
import time
import threading

# Store metrics in memory
metrics = {}
lock = threading.Lock()

def generate_request_id():
    """Generate unique request IDs - unbounded cardinality!"""
    return str(uuid.uuid4())

def generate_user_id():
    """Generate unique user IDs - unbounded cardinality!"""
    return f"user_{random.randint(1, 1000000)}"

def generate_session_id():
    """Generate unique session IDs - even more cardinality!"""
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=32))

def simulate_traffic():
    """Continuously generate new metric labels to simulate production traffic."""
    endpoints = ["/api/users", "/api/orders", "/api/products", "/api/search", "/api/checkout"]
    methods = ["GET", "POST", "PUT", "DELETE"]
    status_codes = [200, 201, 400, 404, 500, 502, 503]
    
    while True:
        # BUG: Using request_id and user_id as labels creates millions of unique series
        request_id = generate_request_id()
        user_id = generate_user_id()
        session_id = generate_session_id()
        endpoint = random.choice(endpoints)
        method = random.choice(methods)
        status = random.choice(status_codes)
        duration = random.uniform(0.01, 5.0)
        
        # This is the problematic metric - each unique combination is a new time series
        key = f'http_request_duration_seconds{{request_id="{request_id}",user_id="{user_id}",session_id="{session_id}",endpoint="{endpoint}",method="{method}",status="{status}"}}'
        
        with lock:
            metrics[key] = duration
            
            # Also track per-user metrics (another cardinality bomb)
            user_key = f'user_request_total{{user_id="{user_id}",request_id="{request_id}",last_endpoint="{endpoint}"}}'
            metrics[user_key] = metrics.get(user_key, 0) + 1
            
            # Per-session tracking
            session_key = f'active_session_info{{session_id="{session_id}",user_id="{user_id}",user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}}'
            metrics[session_key] = 1
        
        # Generate 50 new series every second
        time.sleep(0.02)

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8')
            self.end_headers()
            
            output = []
            output.append('# HELP http_request_duration_seconds HTTP request duration in seconds')
            output.append('# TYPE http_request_duration_seconds gauge')
            output.append('# HELP user_request_total Total requests per user')
            output.append('# TYPE user_request_total counter')
            output.append('# HELP active_session_info Active session information')
            output.append('# TYPE active_session_info gauge')
            
            with lock:
                for key, value in list(metrics.items()):
                    output.append(f'{key} {value:.6f}')
            
            response = '\n'.join(output) + '\n'
            self.wfile.write(response.encode())
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        pass  # Suppress access logs

if __name__ == '__main__':
    # Start traffic simulator in background
    traffic_thread = threading.Thread(target=simulate_traffic, daemon=True)
    traffic_thread.start()
    
    server = HTTPServer(('0.0.0.0', 8000), MetricsHandler)
    print("High-cardinality metrics server starting on :8000")
    print("WARNING: This server intentionally generates unbounded label cardinality!")
    print(f"Metrics endpoint: http://localhost:8000/metrics")
    server.serve_forever()
