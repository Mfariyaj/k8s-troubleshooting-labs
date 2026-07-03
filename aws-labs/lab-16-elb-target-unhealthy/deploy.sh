#!/bin/bash
set -e
echo "🚀 Lab 16: ELB Target Unhealthy"
echo "================================"
echo ""
echo "⚠️  This creates: VPC, EC2, ALB, Target Group"
echo "   Cost: ~$0.03/hour (ALB + EC2 t2.micro)"
echo "   Run cleanup.sh when done!"
echo ""
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

REGION=${AWS_DEFAULT_REGION:-us-east-1}

echo "📦 Creating EC2 with web server + ALB with WRONG health check..."

# Use default VPC
VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)
SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID \
  --query 'Subnets[0:2].SubnetId' --output text)
SUBNET1=$(echo $SUBNETS | awk '{print $1}')
SUBNET2=$(echo $SUBNETS | awk '{print $2}')

# Create Security Group
SG_ID=$(aws ec2 create-security-group --group-name lab16-sg --description "Lab16 ALB+EC2" \
  --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

# Launch EC2 with Apache (serves on / not /healthcheck!)
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --instance-type t2.micro \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET1 \
  --associate-public-ip-address \
  --user-data '#!/bin/bash
yum install -y httpd
echo "Hello from Lab16!" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd' \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=lab16-web},{Key=Lab,Value=lab16}]" \
  --query 'Instances[0].InstanceId' --output text)
echo "   EC2: $INSTANCE_ID (starting...)"

# Create Target Group with WRONG health check path!
TG_ARN=$(aws elbv2 create-target-group \
  --name lab16-broken-tg \
  --protocol HTTP --port 80 \
  --vpc-id $VPC_ID \
  --health-check-path "/healthcheck" \
  --health-check-interval-seconds 10 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 2 \
  --query 'TargetGroups[0].TargetGroupArn' --output text)

# Register EC2 in target group
aws elbv2 register-targets --target-group-arn $TG_ARN \
  --targets Id=$INSTANCE_ID

# Create ALB
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name lab16-broken-alb \
  --subnets $SUBNET1 $SUBNET2 \
  --security-groups $SG_ID \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)
ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN \
  --query 'LoadBalancers[0].DNSName' --output text)

# Create listener
aws elbv2 create-listener --load-balancer-arn $ALB_ARN \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN > /dev/null

echo ""
echo "✅ Setup complete! (Wait 2 minutes for EC2 to start)"
echo ""
echo "📋 Created:"
echo "   EC2: $INSTANCE_ID (Apache serving on /)"
echo "   ALB: $ALB_DNS"
echo "   Target Group: lab16-broken-tg"
echo ""
echo "❌ THE PROBLEM:"
echo "   Health check path is '/healthcheck' but Apache only serves '/'"
echo "   Target will show UNHEALTHY after ~30 seconds!"
echo ""
echo "🔍 YOUR TASK:"
echo "   1. Check: aws elbv2 describe-target-health --target-group-arn $TG_ARN"
echo "   2. See the unhealthy status"
echo "   3. Fix: Change health check path from '/healthcheck' to '/'"
echo "   4. Verify targets become healthy"
echo ""
echo "🛠️ Fix command:"
echo "   aws elbv2 modify-target-group --target-group-arn $TG_ARN --health-check-path '/'"
echo ""
echo "🧹 When done: ./cleanup.sh"

# Save for cleanup
echo "$ALB_ARN" > /tmp/lab16-alb-arn
echo "$TG_ARN" > /tmp/lab16-tg-arn
echo "$INSTANCE_ID" > /tmp/lab16-instance
echo "$SG_ID" > /tmp/lab16-sg
