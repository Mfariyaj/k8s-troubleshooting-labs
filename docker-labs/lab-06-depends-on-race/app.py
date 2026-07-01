#!/usr/bin/env python3
"""Flask app that crashes if database isn't ready."""

import os
import sys
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

DATABASE_URL = os.environ.get('DATABASE_URL', 'postgresql://appuser:secret123@db:5432/myapp')

def connect_database():
    """Attempt to connect to the database - NO retry logic (the bug)."""
    print(f"Connecting to database at db:5432...")
    try:
        conn = psycopg2.connect(DATABASE_URL, connect_timeout=3)
        conn.close()
        print("✅ Database connection successful!")
        return True
    except psycopg2.OperationalError as e:
        print(f"❌ psycopg2.OperationalError: could not connect to server: Connection refused")
        print(f'    Is the server running on host "db" and accepting')
        print(f"    TCP/IP connections on port 5432?")
        print(f"\nApplication crashed! Database not ready.")
        return False

@app.route('/')
def index():
    return jsonify({"message": "Order Management System", "status": "running"})

@app.route('/health')
def health():
    try:
        conn = psycopg2.connect(DATABASE_URL, connect_timeout=2)
        conn.close()
        return jsonify({"status": "healthy", "database": "connected"})
    except Exception:
        return jsonify({"status": "unhealthy", "database": "disconnected"}), 503

if __name__ == '__main__':
    # Try to connect immediately on startup (no retry logic)
    if not connect_database():
        sys.exit(1)
    
    print("Starting Flask application on port 5000...")
    app.run(host='0.0.0.0', port=5000)
