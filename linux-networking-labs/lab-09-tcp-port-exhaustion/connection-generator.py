#!/usr/bin/env python3
"""
Simulates TCP port exhaustion by opening many connections.
Opens connections to localhost on various ports to exhaust ephemeral ports.
Uses a local listener to avoid needing external connectivity.
"""

import socket
import sys
import os
import time
import signal
import threading

# Safety: limit max connections (real ephemeral range is ~28000 ports)
MAX_CONNECTIONS = int(os.environ.get('LAB09_MAX_CONNS', '5000'))
LISTEN_PORT = 19999

sockets = []
server_socket = None

def signal_handler(sig, frame):
    print(f"\n[port-exhaust] Received signal {sig}, cleaning up...")
    cleanup()
    sys.exit(0)

def cleanup():
    global server_socket
    for s in sockets:
        try:
            s.close()
        except:
            pass
    if server_socket:
        try:
            server_socket.close()
        except:
            pass

def start_listener():
    """Start a TCP listener that accepts all connections"""
    global server_socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('127.0.0.1', LISTEN_PORT))
    server_socket.listen(MAX_CONNECTIONS)
    
    while True:
        try:
            conn, addr = server_socket.accept()
            # Don't close the connection - let it stay open
            sockets.append(conn)
        except:
            break

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

print(f"[port-exhaust] PID: {os.getpid()}")
print(f"[port-exhaust] Starting TCP port exhaustion simulation...")
print(f"[port-exhaust] Target: {MAX_CONNECTIONS} connections")
sys.stdout.flush()

# Start listener thread
listener_thread = threading.Thread(target=start_listener, daemon=True)
listener_thread.start()
time.sleep(1)

# Open many connections to exhaust ephemeral ports
connected = 0
failed = 0

for i in range(MAX_CONNECTIONS):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('127.0.0.1', LISTEN_PORT))
        sockets.append(s)
        connected += 1
        
        if connected % 500 == 0:
            print(f"[port-exhaust] Opened {connected} connections...")
            sys.stdout.flush()
    except OSError as e:
        failed += 1
        if failed > 10:
            print(f"[port-exhaust] Port exhaustion reached at {connected} connections")
            print(f"[port-exhaust] Error: {e}")
            sys.stdout.flush()
            break

print(f"[port-exhaust] Holding {connected} connections open...")
print(f"[port-exhaust] Ephemeral ports exhausted!")
sys.stdout.flush()

# Keep connections open until killed
try:
    while True:
        time.sleep(5)
except KeyboardInterrupt:
    pass
finally:
    cleanup()
