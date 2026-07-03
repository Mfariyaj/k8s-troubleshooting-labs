#!/bin/bash
set -e
echo "🚀 Lab 09: VPC No Internet (Missing NAT Gateway)"
echo "=================================================="
echo ""
echo "⚠️  This will create real AWS resources!"
echo "   Cost: ~$0.05/hour for NAT Gateway (after you fix it)"
echo "   Run cleanup.sh when done to avoid charges!"
echo ""
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

REGION=${AWS_DEFAULT_REGION:-us-east-1}
LAB_TAG="Key=Lab,Value=lab09-vpc-no-internet"

echo "📦 Creating VPC with private subnet (NO internet access)..."

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.99.0.0/16 \
  --tag-specifications "ResourceType=vpc,Tags=[{$LAB_TAG},{Key=Name,Value=lab09-broken-vpc}]" \
  --query 'Vpc.VpcId' --output text)
echo "   VPC: $VPC_ID"

# Create Internet Gateway (for public subnet)
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{$LAB_TAG}]" \
  --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create public subnet
PUB_SUBNET=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.99.1.0/24 \
  --availability-zone ${REGION}a \
  --tag-specifications "ResourceType=subnet,Tags=[{$LAB_TAG},{Key=Name,Value=lab09-public}]" \
  --query 'Subnet.SubnetId' --output text)

# Create PRIVATE subnet (this is where the problem is - NO route to internet!)
PRIV_SUBNET=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.99.2.0/24 \
  --availability-zone ${REGION}a \
  --tag-specifications "ResourceType=subnet,Tags=[{$LAB_TAG},{Key=Name,Value=lab09-private-BROKEN}]" \
  --query 'Subnet.SubnetId' --output text)
echo "   Private subnet (BROKEN): $PRIV_SUBNET"

# Public route table (has IGW route)
PUB_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{$LAB_TAG},{Key=Name,Value=lab09-public-rt}]" \
  --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PUB_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $PUB_RT --subnet-id $PUB_SUBNET > /dev/null

# Private route table (NO route to internet - THIS IS THE BUG!)
PRIV_RT=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{$LAB_TAG},{Key=Name,Value=lab09-private-rt-BROKEN}]" \
  --query 'RouteTable.RouteTableId' --output text)
aws ec2 associate-route-table --route-table-id $PRIV_RT --subnet-id $PRIV_SUBNET > /dev/null
# NOTE: No 0.0.0.0/0 route! That's the bug!

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Created resources:"
echo "   VPC: $VPC_ID"
echo "   Public subnet: $PUB_SUBNET (has internet via IGW)"
echo "   Private subnet: $PRIV_SUBNET (NO internet - BROKEN!)"
echo "   Private route table: $PRIV_RT (missing 0.0.0.0/0 route)"
echo ""
echo "❌ THE PROBLEM:"
echo "   The private subnet has NO route to the internet."
echo "   Any EC2/Lambda in this subnet CANNOT reach external services."
echo ""
echo "🔍 YOUR TASK:"
echo "   1. Create a NAT Gateway in the PUBLIC subnet ($PUB_SUBNET)"
echo "   2. Add route 0.0.0.0/0 → NAT Gateway in the private route table ($PRIV_RT)"
echo "   3. Verify internet access works from private subnet"
echo ""
echo "🛠️ Useful commands:"
echo "   aws ec2 describe-route-tables --route-table-ids $PRIV_RT"
echo "   aws ec2 allocate-address --domain vpc"
echo "   aws ec2 create-nat-gateway --subnet-id $PUB_SUBNET --allocation-id <eip-id>"
echo "   aws ec2 create-route --route-table-id $PRIV_RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id <nat-id>"
echo ""
echo "🧹 When done: ./cleanup.sh"

# Save IDs for cleanup
echo "$VPC_ID" > /tmp/lab09-vpc-id
echo "$IGW_ID" > /tmp/lab09-igw-id
