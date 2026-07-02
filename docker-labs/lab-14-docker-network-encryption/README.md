## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 14: Docker Swarm Overlay Network Encryption — Cross-Node Communication Failure

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team deployed a Docker Swarm cluster across 3 nodes in AWS. After enabling overlay network encryption for PCI-DSS compliance, services on different nodes can no longer communicate. Services on the same node work fine, but cross-node traffic silently drops.

The overlay network uses IPSec ESP (Encapsulating Security Payload) for encryption. The cloud security groups only allow standard Docker Swarm ports (2377, 7946, 4789) but forgot to allow IP protocol 50 (ESP). Additionally, the encryption adds overhead that causes MTU issues, and the gossip protocol port is only open for TCP but not UDP.

## Symptoms Observed

```
$ docker service create --name web --replicas 3 --network encrypted-net nginx
ID: abc123def456
Overall progress: 1 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: starting  [===============>                                   ]

$ docker service logs web
web.1.x1y2z3 | 2024/01/15 10:22:13 [error] Connection to web.2 timed out
web.3.a4b5c6 | 2024/01/15 10:22:14 [error] upstream connect timeout (110: Connection timed out)

$ docker exec web.1.x1y2z3 ping -c3 web.2.a4b5c6
PING web.2.a4b5c6 (10.0.1.4): 56 data bytes
--- web.2.a4b5c6 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss

$ docker network inspect encrypted-net
[
  {
    "Name": "encrypted-net",
    "Driver": "overlay",
    "Options": {
      "encrypted": "",
      "com.docker.network.driver.mtu": "1500"
    },
    "IPAM": {
      "Config": [{"Subnet": "10.0.1.0/24", "Gateway": "10.0.1.1"}]
    }
  }
]

$ tcpdump -i eth0 -n proto 50
tcpdump: verbose output suppressed
0 packets captured

$ tcpdump -i eth0 port 4789
10:23:01 IP 172.31.1.10.4789 > 172.31.2.20.4789: OTV, flags [I]
10:23:01 IP 172.31.1.10.4789 > 172.31.2.20.4789: OTV, flags [I]
(packets sent but no responses)

$ docker node ls
ID           HOSTNAME   STATUS  AVAILABILITY  MANAGER STATUS  ENGINE VERSION
node1 *      swarm-mgr  Ready   Active        Leader          24.0.7
node2        swarm-w1   Ready   Active                        24.0.7
node3        swarm-w2   Ready   Active                        24.0.7

$ dmesg | grep -i ipsec
[42918.423] xfrm_user: Unknown SA type
[42918.424] NET: Registered PF_KEY protocol family

$ iptables -L -n | grep -i esp
(empty - no ESP rules)

# Security group check (simulated)
$ aws ec2 describe-security-groups --group-id sg-0abc123
{
  "IpPermissions": [
    {"IpProtocol": "tcp", "FromPort": 2377, "ToPort": 2377},
    {"IpProtocol": "tcp", "FromPort": 7946, "ToPort": 7946},
    {"IpProtocol": "udp", "FromPort": 4789, "ToPort": 4789}
  ]
}
```

## What's Broken

1. **Security group missing IP protocol 50 (ESP)** — IPSec ESP packets blocked by cloud firewall
2. **Port 7946/UDP not open** — gossip protocol needs both TCP AND UDP
3. **MTU set to 1500** — encryption adds ~50-100 byte overhead, effective MTU should be ~1400
4. **No ESP rules in iptables** — host firewall also blocking protocol 50
5. **Gossip port 7946 only allows TCP** — Swarm node discovery needs UDP for SWIM protocol

## Debugging Commands

```bash
# Check overlay network details
docker network inspect encrypted-net
docker network ls --filter driver=overlay

# Test cross-node connectivity (from inside container)
docker exec <container> ping -c3 -s 1400 <other-container>
docker exec <container> traceroute <other-container>

# Check VXLAN traffic (port 4789)
tcpdump -i eth0 -n port 4789
tcpdump -i eth0 -n proto 50

# Verify ESP/IPSec kernel support
modprobe esp4
lsmod | grep esp
cat /proc/net/xfrm_stat

# Check MTU on overlay interface
docker exec <container> ip link show eth0
docker exec <container> cat /sys/class/net/eth0/mtu

# Inspect security group rules (AWS)
aws ec2 describe-security-groups --group-id <sg-id>

# Check iptables for ESP
iptables -L -n -v | grep -i "esp\|proto 50"
iptables -L INPUT -n --line-numbers

# Test with different packet sizes (MTU discovery)
docker exec <container> ping -c3 -M do -s 1400 <target>
docker exec <container> ping -c3 -M do -s 1300 <target>

# Check Swarm gossip
tcpdump -i eth0 -n port 7946
ss -tulnp | grep 7946

# Verify Docker Swarm ports
docker info | grep -A10 "Swarm"

# Check xfrm (IPSec) state
ip xfrm state
ip xfrm policy
```

## Hints

<details>
<summary>Hint 1</summary>
Docker overlay network encryption uses IPSec ESP (IP protocol 50, NOT a TCP/UDP port). Your security groups must allow protocol 50 in addition to the standard Swarm ports. In AWS: `aws ec2 authorize-security-group-ingress --protocol 50 --cidr <swarm-subnet>`.
</details>

<details>
<summary>Hint 2</summary>
Port 7946 needs BOTH TCP and UDP. TCP handles the initial Swarm join and metadata exchange, while UDP handles the SWIM protocol gossip for membership and health. Without UDP/7946, nodes can't discover container placements on other nodes.
</details>

<details>
<summary>Hint 3</summary>
With overlay encryption enabled, the effective MTU drops by ~50-100 bytes (ESP header + IV + padding + authentication trailer). Set `--opt com.docker.network.driver.mtu=1400` on the overlay network or recreate it with the correct MTU to prevent silent packet drops for large frames.
</details>

## Learning Objectives

- Understanding Docker Swarm overlay network internals (VXLAN + IPSec)
- Debugging encrypted overlay communication failures
- Cloud security group configuration for container orchestration
- MTU path discovery and encrypted tunnel overhead calculation
- SWIM gossip protocol requirements (TCP + UDP)
- IPSec ESP kernel module and xfrm framework debugging
