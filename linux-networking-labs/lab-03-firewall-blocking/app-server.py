#!/usr/bin/env python3
"""Simple HTTP server that serves on port 8080.
The server works fine - the problem is the firewall blocking access."""

from http.server import HTTPServer, SimpleHTTPRequestHandler
import os
import sys

class LabHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        response = """<html>
<head><title>Lab 03 - App Server</title></head>
<body>
<h1>Application Server Running!</h1>
<p>If you can see this, you've fixed the firewall issue.</p>
<p>Server PID: {}</p>
</body>
</html>""".format(os.getpid())
        self.wfile.write(response.encode())

    def log_message(self, format, *args):
        # Suppress output to avoid cluttering terminal
        pass

if __name__ == '__main__':
    port = 8080
    server = HTTPServer(('0.0.0.0', port), LabHandler)
    print(f"Lab 03 app server running on port {port} (PID: {os.getpid()})")
    sys.stdout.flush()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
