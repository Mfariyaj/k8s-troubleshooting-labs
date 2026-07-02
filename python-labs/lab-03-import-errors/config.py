"""
Configuration for the health checker.
"""

# BUG 3: Circular import — this file imports from utils, and utils imports from here
from utils import DEFAULT_TIMEOUT

SERVER_LIST = [
    {"host": "web-01.prod.internal", "port": 8080, "name": "Web Server 1"},
    {"host": "web-02.prod.internal", "port": 8080, "name": "Web Server 2"},
    {"host": "api-01.prod.internal", "port": 3000, "name": "API Server"},
    {"host": "db-01.prod.internal", "port": 5432, "name": "Database"},
]

TIMEOUT = DEFAULT_TIMEOUT
