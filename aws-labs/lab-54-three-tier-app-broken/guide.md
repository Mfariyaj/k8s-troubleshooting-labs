# 📖 Detailed Guide: Three-Tier Application Troubleshooting

## Understanding the Problem
Classic 3-tier architecture (ALB → EC2/ECS → RDS) where each layer has a different connectivity issue.

---

## Architecture:
```
Users
  │
  ▼
┌─────────────────────┐
│ ALB (Application     │  Layer 1: Load Balancer
│ Load Balancer)       │  Issues: Health check, SG, listeners
│ Port: 443 (HTTPS)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ EC2 / ECS           │  Layer 2: Application
│ (Application Tier)  │  Issues: SG inbound, app config, env vars
│ Port: 8080          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ RDS (Database)      │  Layer 3: Database
│ Port: 3306 (MySQL)  │  Issues: SG, subnet group, credentials
└─────────────────────┘
```

---

## 🖥️ AWS Console - Debug Each Layer

### Layer 1: ALB → EC2 (Is traffic reaching the app?)
1. **EC2 → Load Balancers** → Select ALB
2. **Listeners** tab → Ensure port 443 forwards to Target Group
3. **Target Groups** → Check **Targets** tab → Are they `healthy`?
4. If `unhealthy`:
   - Check health check path (e.g., `/health`)
   - Check health check port (must match app port)
   - Check **Security Group** of ALB allows outbound to EC2 port

### Layer 2: EC2 (Is the app running?)
1. **EC2 → Instances** → Select your instance
2. **Security Group** → Inbound must allow port 8080 from ALB's SG
3. **Connect** (Session Manager) → Check app:
   ```bash
   curl localhost:8080/health     # App responding?
   systemctl status myapp         # Service running?
   journalctl -u myapp --tail 50  # Error logs?
   ```

### Layer 3: EC2 → RDS (Can app reach database?)
1. **RDS → Databases** → Select your DB
2. **Connectivity** → Note the **Endpoint** and **Port**
3. **Security Group** → Inbound must allow port 3306 from EC2's SG
4. Check **Subnet Group** — RDS must be in same VPC as EC2
5. From EC2:
   ```bash
   telnet rds-endpoint.region.rds.amazonaws.com 3306   # Can connect?
   mysql -h rds-endpoint -u admin -p                   # Auth works?
   ```

---

## 💻 AWS CLI - Systematic Debug

```bash
# === Layer 1: ALB ===
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...:targetgroup/my-tg/xxx
# If "State": "unhealthy" → check Reason field

# Check ALB Security Group
aws ec2 describe-security-groups --group-ids sg-ALB \
  --query 'SecurityGroups[].IpPermissionsEgress'

# === Layer 2: EC2 ===
# Check EC2 Security Group (inbound from ALB?)
aws ec2 describe-security-groups --group-ids sg-EC2 \
  --query 'SecurityGroups[].IpPermissions[].[FromPort, ToPort, UserIdGroupPairs[].GroupId]'

# Connect and check app
aws ssm start-session --target i-xxx
# Inside: curl localhost:8080/health

# === Layer 3: RDS ===
# Check RDS endpoint and port
aws rds describe-db-instances --db-instance-identifier mydb \
  --query 'DBInstances[].[Endpoint.Address, Endpoint.Port, DBSubnetGroup.VpcId]'

# Check RDS Security Group
aws ec2 describe-security-groups --group-ids sg-RDS \
  --query 'SecurityGroups[].IpPermissions[].[FromPort, UserIdGroupPairs[].GroupId]'
# Must allow from sg-EC2 on port 3306!
```

---

## 🧠 Common Issues per Layer

| Layer | Symptom | Common Cause | Fix |
|-------|---------|-------------|-----|
| ALB→EC2 | 502 Bad Gateway | Health check failing | Fix health check path/port |
| ALB→EC2 | 504 Timeout | EC2 SG blocks ALB | Add inbound rule from ALB SG |
| EC2→RDS | Connection refused | RDS SG blocks EC2 | Add inbound 3306 from EC2 SG |
| EC2→RDS | Access denied | Wrong credentials | Check env vars, Secrets Manager |
| EC2→RDS | Can't resolve hostname | RDS in different VPC | Check VPC, subnet group |
| All | Timeout | NACL blocking | Check NACL allows inbound+outbound |
