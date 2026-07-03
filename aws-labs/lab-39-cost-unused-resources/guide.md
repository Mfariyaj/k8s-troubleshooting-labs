# 📖 Detailed Guide: Finding & Removing Unused AWS Resources

## Understanding the Problem
Companies waste 30-40% of cloud spend on unused resources. This guide helps you find and remove them.

---

## 🖥️ AWS Console Steps

### Step 1: Find unattached EBS volumes
1. **EC2 → Volumes** → Filter: **State = available**
2. These volumes are NOT attached to any instance = wasting money!
3. Check if they have snapshots → Delete volumes

### Step 2: Find idle Elastic Load Balancers
1. **EC2 → Load Balancers**
2. Check **Monitoring** tab → If 0 requests for 7+ days = idle
3. Check **Target Groups** → If 0 healthy targets = useless

### Step 3: Find old EBS snapshots
1. **EC2 → Snapshots** → Sort by **Start time**
2. Snapshots older than 90 days without lifecycle policy = review
3. Check if the source volume still exists

### Step 4: Find unused Elastic IPs
1. **EC2 → Elastic IPs** → Filter: **Association ID = empty**
2. Unassociated EIPs cost $3.65/month each!

### Step 5: Find stopped EC2 instances
1. **EC2 → Instances** → Filter: **State = stopped**
2. Stopped instances still pay for EBS volumes!
3. Terminate if not needed, or snapshot and terminate

---

## 💻 AWS CLI Steps

```bash
# Unattached EBS volumes (WASTING MONEY!)
aws ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query 'Volumes[].[VolumeId, Size, CreateTime]' \
  --output table

# Unassociated Elastic IPs ($3.65/month each!)
aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==null].[PublicIp, AllocationId]' \
  --output table

# Old snapshots (>90 days)
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<`2024-01-01`].[SnapshotId, VolumeSize, StartTime]' \
  --output table

# Idle Load Balancers (check CloudWatch for RequestCount=0)
aws elbv2 describe-load-balancers --query 'LoadBalancers[].[LoadBalancerName, State.Code]'

# Stopped instances (still paying for EBS!)
aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=stopped \
  --query 'Reservations[].Instances[].[InstanceId, InstanceType, LaunchTime]' \
  --output table

# DELETE unused resources:
aws ec2 delete-volume --volume-id vol-xxx
aws ec2 release-address --allocation-id eipalloc-xxx
aws ec2 delete-snapshot --snapshot-id snap-xxx
aws ec2 terminate-instances --instance-ids i-xxx
```

---

## 🧠 Cost Savings Checklist

| Resource | Check | Monthly Cost if Unused |
|----------|-------|----------------------|
| EBS Volume (100GB gp3) | Status = available | ~$8/month |
| Elastic IP (unassociated) | No AssociationId | $3.65/month |
| NAT Gateway (idle) | 0 bytes processed | $32/month + data |
| RDS (stopped >7 days) | Auto-starts after 7d! | $50-500/month |
| ELB (no traffic) | 0 requests | $16-25/month |
| EKS cluster (no workload) | Running control plane | $73/month |

### Automation:
```bash
# Use AWS Cost Explorer:
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Use AWS Trusted Advisor (free checks):
aws support describe-trusted-advisor-checks --language en \
  --query 'checks[?category==`cost_optimizing`].name'
```
