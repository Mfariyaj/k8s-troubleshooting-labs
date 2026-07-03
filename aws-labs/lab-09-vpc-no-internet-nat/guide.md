# 📖 Detailed Guide: VPC No Internet Access

## Understanding the Problem
EC2 instances in a PRIVATE subnet can't reach the internet. They need a NAT Gateway in a PUBLIC subnet.

---

## 🖥️ AWS Console Steps

### Step 1: Check the subnet type
1. **VPC → Subnets** → Find your instance's subnet
2. Check the **Route Table** associated with it
3. If route table has `0.0.0.0/0 → igw-xxx` = PUBLIC subnet ✅
4. If NO route to `0.0.0.0/0` = PRIVATE subnet (no internet!) ❌

### Step 2: Create NAT Gateway (if missing)
1. **VPC → NAT Gateways** → **Create NAT Gateway**
2. Select a **PUBLIC subnet** (one with IGW route)
3. Allocate an **Elastic IP** → Click Create

### Step 3: Update Private Subnet Route Table
1. **VPC → Route Tables** → Find the private subnet's route table
2. **Routes** tab → **Edit routes** → **Add route**
3. Destination: `0.0.0.0/0` → Target: `nat-xxx` (your NAT Gateway)
4. Click **Save changes**

### Step 4: Verify
1. SSH into EC2 instance in private subnet
2. Run: `curl -I https://google.com` — should work now

---

## 💻 AWS CLI Steps

```bash
# Step 1: Find instance's subnet
aws ec2 describe-instances --instance-ids i-xxx \
  --query 'Reservations[].Instances[].SubnetId'

# Step 2: Check route table for that subnet
aws ec2 describe-route-tables \
  --filters Name=association.subnet-id,Values=subnet-xxx \
  --query 'RouteTables[].Routes[]'
# Look for 0.0.0.0/0 → should point to nat-xxx or igw-xxx

# Step 3: Create NAT Gateway (in public subnet)
aws ec2 allocate-address --domain vpc
# Get AllocationId

aws ec2 create-nat-gateway \
  --subnet-id subnet-PUBLIC \
  --allocation-id eipalloc-xxx

# Step 4: Add route to private route table
aws ec2 create-route \
  --route-table-id rtb-PRIVATE \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id nat-xxx

# Step 5: Verify from instance
aws ssm start-session --target i-xxx
curl -I https://google.com
```

---

## 🧠 Architecture
```
Internet
    │
Internet Gateway (igw-xxx)
    │
┌───────────────────────────┐
│ PUBLIC Subnet              │
│ Route: 0.0.0.0/0 → igw   │
│                           │
│ [NAT Gateway] ← Elastic IP│
└───────────────────────────┘
    │
    │ NAT translates private IP → public IP
    │
┌───────────────────────────┐
│ PRIVATE Subnet             │
│ Route: 0.0.0.0/0 → nat   │ ← This route is often MISSING!
│                           │
│ [EC2 Instance]            │
└───────────────────────────┘
```

### Common Mistakes:
| Mistake | Symptom | Fix |
|---------|---------|-----|
| No NAT Gateway | Timeout on all outbound | Create NAT in public subnet |
| NAT in private subnet | NAT itself can't reach internet | Move NAT to public subnet |
| Route table not updated | Instance can't find path out | Add 0.0.0.0/0 → nat route |
| Wrong route table | Route exists but wrong subnet uses it | Associate correct RT with subnet |
| NAT in different AZ | Cross-AZ traffic works but costs $$ | Create NAT per AZ |
