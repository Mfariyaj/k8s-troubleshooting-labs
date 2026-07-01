# Complex security rules for a microservices platform
# Expected outcome: 12 ingress rules total (4 apps × 3 rules with multiple port ranges)

security_rules = [
  {
    app_name    = "api-gateway"
    environment = "production"
    rules = [
      {
        description = "HTTPS from public"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 443, to_port = 443 }
        ]
        cidrs = ["0.0.0.0/0"]
      },
      {
        description = "HTTP redirect from public"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 80, to_port = 80 }
        ]
        cidrs = ["0.0.0.0/0"]
      },
      {
        description = "Admin panel from VPN"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 8443, to_port = 8443 },
          { from_port = 9090, to_port = 9090 }
        ]
        cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
      }
    ]
  },
  {
    app_name    = "backend-services"
    environment = "production"
    rules = [
      {
        description = "gRPC from internal"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 50051, to_port = 50059 }
        ]
        cidrs = ["10.0.0.0/8"]
      },
      {
        description = "Metrics and health"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 8080, to_port = 8080 },
          { from_port = 9090, to_port = 9090 },
          { from_port = 9100, to_port = 9100 }
        ]
        cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
      },
      {
        description = "Database access"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 5432, to_port = 5432 },
          { from_port = 6379, to_port = 6379 }
        ]
        cidrs = ["10.0.100.0/24"]
      }
    ]
  },
  {
    app_name    = "message-queue"
    environment = "production"
    rules = [
      {
        description = "AMQP from services"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 5672, to_port = 5672 },
          { from_port = 15672, to_port = 15672 }
        ]
        cidrs = ["10.0.0.0/8"]
      },
      {
        description = "Kafka from services"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 9092, to_port = 9094 }
        ]
        cidrs = ["10.0.0.0/8"]
      },
      {
        description = "ZooKeeper internal"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 2181, to_port = 2181 },
          { from_port = 2888, to_port = 2888 },
          { from_port = 3888, to_port = 3888 }
        ]
        cidrs = ["10.0.50.0/24"]
      }
    ]
  },
  {
    app_name    = "monitoring"
    environment = "production"
    rules = [
      {
        description = "Prometheus scrape"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 9090, to_port = 9090 },
          { from_port = 9093, to_port = 9093 },
          { from_port = 9100, to_port = 9100 }
        ]
        cidrs = ["10.0.0.0/8"]
      },
      {
        description = "Grafana UI"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 3000, to_port = 3000 }
        ]
        cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
      },
      {
        description = "Alertmanager"
        protocol    = "tcp"
        port_ranges = [
          { from_port = 9093, to_port = 9094 }
        ]
        cidrs = ["10.0.0.0/8"]
      }
    ]
  }
]

egress_rules = [
  {
    description = "HTTPS outbound"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidrs       = ["0.0.0.0/0"]
  },
  {
    description = "DNS outbound"
    protocol    = "udp"
    from_port   = 53
    to_port     = 53
    cidrs       = ["0.0.0.0/0"]
  },
  {
    description = "Internal services"
    protocol    = "tcp"
    from_port   = 1024
    to_port     = 65535
    cidrs       = ["10.0.0.0/8"]
  }
]

enable_egress = true
environment   = "production"
team          = "platform"
