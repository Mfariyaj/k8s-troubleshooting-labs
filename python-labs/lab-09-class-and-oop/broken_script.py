#!/usr/bin/env python3
"""
Server Infrastructure Manager (OOP)
=====================================
This script models a server hierarchy using classes for infrastructure management.

INTENDED BEHAVIOR:
- Define a base Server class with common properties
- Create subclasses for WebServer, DatabaseServer, etc.
- Manage a fleet of servers with health checks and reporting
"""


class Server:
    """Base class for all server types."""
    
    # BUG 1: __init__ is missing self parameter
    def __init__(hostname, ip_address, cpu_cores, ram_gb):
        self.hostname = hostname
        self.ip_address = ip_address
        self.cpu_cores = cpu_cores
        self.ram_gb = ram_gb
        self.status = "stopped"
        self._uptime_hours = 0
    
    def start(self):
        """Start the server."""
        self.status = "running"
        print(f"  ▶️  {self.hostname} started")
    
    def stop(self):
        """Stop the server."""
        self.status = "stopped"
        print(f"  ⏹️  {self.hostname} stopped")
    
    # BUG 2: @property used incorrectly — getter defined but trying to call as method
    @property
    def uptime(self):
        """Get server uptime in hours."""
        return self._uptime_hours
    
    def get_info(self):
        """Return server info as a formatted string."""
        return f"{self.hostname} ({self.ip_address}) - {self.cpu_cores} CPU, {self.ram_gb}GB RAM [{self.status}]"


class WebServer(Server):
    """Web server with HTTP-specific attributes."""
    
    # BUG 3: Not calling super().__init__() — parent attributes don't get set
    def __init__(self, hostname, ip_address, cpu_cores, ram_gb, port=80, max_connections=1000):
        # Missing super().__init__() call!
        self.port = port
        self.max_connections = max_connections
        self.active_connections = 0
    
    def handle_request(self):
        """Simulate handling an HTTP request."""
        if self.active_connections >= self.max_connections:
            print(f"  ⚠️  {self.hostname}: Max connections reached!")
            return False
        self.active_connections += 1
        return True
    
    def get_info(self):
        """Override parent method to include web server details."""
        base_info = super().get_info()
        return f"{base_info} | Port: {self.port}, Connections: {self.active_connections}/{self.max_connections}"


class DatabaseServer(Server):
    """Database server with storage attributes."""
    
    def __init__(self, hostname, ip_address, cpu_cores, ram_gb, storage_gb, engine="postgres"):
        super().__init__(hostname, ip_address, cpu_cores, ram_gb)
        self.storage_gb = storage_gb
        self.engine = engine
        self.connections = []
    
    def connect(self, client_name):
        """Register a new database connection."""
        self.connections.append(client_name)
        print(f"  📊 {self.hostname}: New connection from {client_name}")
    
    def get_info(self):
        """Override parent method to include DB details."""
        base_info = super().get_info()
        return f"{base_info} | Engine: {self.engine}, Storage: {self.storage_gb}GB, Clients: {len(self.connections)}"


class ServerFleet:
    """Manages a collection of servers."""
    
    def __init__(self):
        self.servers = []
    
    def add_server(self, server):
        """Add a server to the fleet."""
        self.servers.append(server)
    
    def start_all(self):
        """Start all servers in the fleet."""
        print("\n🚀 Starting all servers...")
        for server in self.servers:
            server.start()
    
    def get_fleet_report(self):
        """Generate a fleet status report."""
        print("\n" + "=" * 70)
        print("  Server Fleet Report")
        print("=" * 70)
        
        for server in self.servers:
            # BUG 2 manifests here: trying to call uptime() as a method, but it's a @property
            print(f"  {server.get_info()} | Uptime: {server.uptime()}h")
        
        print("=" * 70)
        total_cpu = sum(s.cpu_cores for s in self.servers)
        total_ram = sum(s.ram_gb for s in self.servers)
        print(f"  Fleet Total: {len(self.servers)} servers, {total_cpu} cores, {total_ram}GB RAM")
        print("=" * 70)


def main():
    # Create fleet
    fleet = ServerFleet()
    
    # Create servers
    web1 = WebServer("web-prod-01", "10.0.1.10", 4, 16, port=8080)
    web2 = WebServer("web-prod-02", "10.0.1.11", 4, 16, port=8080)
    db1 = DatabaseServer("db-primary", "10.0.2.10", 16, 64, 500, engine="postgres")
    db2 = DatabaseServer("db-replica", "10.0.2.11", 8, 32, 500, engine="postgres")
    
    # Add to fleet
    fleet.add_server(web1)
    fleet.add_server(web2)
    fleet.add_server(db1)
    fleet.add_server(db2)
    
    # Start servers
    fleet.start_all()
    
    # Simulate some activity
    print("\n📡 Simulating traffic...")
    for _ in range(5):
        web1.handle_request()
    db1.connect("payment-service")
    db1.connect("user-service")
    
    # Generate report
    fleet.get_fleet_report()


if __name__ == "__main__":
    main()
