## Solution: Docker Network Encryption

### Root Cause

Encrypted overlay networks in Docker Swarm use IPsec (ESP protocol) for encryption. Problems:
1. **Firewall/Security Groups**: UDP/4789 (VXLAN) and IP protocol 50 (ESP) not allowed between nodes
2. **MTU too high**: Standard 1500 MTU doesn't account for encryption overhead (~50-100 bytes), causing packet fragmentation and drops
3. **Cross-node placement**: Services forced onto different nodes trigger encryption path

### Step-by-Step Fix

1. Open required ports in firewall/security groups
2. Reduce MTU to account for encryption overhead (use 1400)
3. Verify node connectivity

### Firewall Rules

```bash
# On all swarm nodes — open required ports
sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT   # VXLAN
sudo iptables -A INPUT -p 50 -j ACCEPT                 # ESP (IPsec)
sudo iptables -A INPUT -p udp --dport 7946 -j ACCEPT   # Serf (gossip)
sudo iptables -A INPUT -p tcp --dport 7946 -j ACCEPT   # Serf (gossip)

# For AWS Security Groups:
# - UDP 4789 (VXLAN)
# - IP Protocol 50 (ESP) — NOT a port, it's protocol number
# - TCP/UDP 7946 (node communication)
```

### Fixed docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - encrypted-net
    deploy:
      replicas: 3

  api:
    image: python:3.11-alpine
    command: python -m http.server 5000
    networks:
      - encrypted-net
    deploy:
      replicas: 2

  redis:
    image: redis:7-alpine
    networks:
      - encrypted-net

  healthcheck:
    image: busybox
    command: sh -c "while true; do wget -qO- http://web:80/ && echo OK || echo FAIL; sleep 5; done"
    networks:
      - encrypted-net

networks:
  encrypted-net:
    driver: overlay
    driver_opts:
      encrypted: ""
      # Fixed: reduced MTU for encryption overhead
      com.docker.network.driver.mtu: "1400"
    ipam:
      config:
        - subnet: 10.0.1.0/24
```

### Verification

```bash
docker stack deploy -c docker-compose.yml mystack
docker service ls
# Test cross-node connectivity
docker exec <web-container> wget -qO- http://api:5000
# Check MTU
docker exec <web-container> ip link show eth0 | grep mtu
# Should show 1400
```
