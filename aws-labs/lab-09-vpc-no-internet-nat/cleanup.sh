#!/bin/bash
echo "🧹 Cleaning up Lab 09..."
VPC_ID=$(cat /tmp/lab09-vpc-id 2>/dev/null)

if [ -z "$VPC_ID" ]; then
  echo "No VPC ID found. Trying to find by tag..."
  VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Lab,Values=lab09-vpc-no-internet \
    --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
fi

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
  echo "No lab resources found. Already cleaned?"
  exit 0
fi

echo "   Deleting VPC: $VPC_ID and all associated resources..."

# Delete NAT Gateways
for nat in $(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=$VPC_ID \
  --query 'NatGateways[].NatGatewayId' --output text 2>/dev/null); do
  aws ec2 delete-nat-gateway --nat-gateway-id $nat
  echo "   Deleted NAT: $nat (waiting 30s for deletion...)"
  sleep 30
done

# Release EIPs tagged for this lab
for eip in $(aws ec2 describe-addresses --filters Name=domain,Values=vpc \
  --query 'Addresses[?AssociationId==null].AllocationId' --output text 2>/dev/null); do
  aws ec2 release-address --allocation-id $eip 2>/dev/null
done

# Detach and delete IGW
for igw in $(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC_ID \
  --query 'InternetGateways[].InternetGatewayId' --output text); do
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $VPC_ID
  aws ec2 delete-internet-gateway --internet-gateway-id $igw
done

# Delete subnets
for subnet in $(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID \
  --query 'Subnets[].SubnetId' --output text); do
  aws ec2 delete-subnet --subnet-id $subnet
done

# Delete route tables (non-main)
for rt in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID \
  --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text); do
  aws ec2 delete-route-table --route-table-id $rt
done

# Delete VPC
aws ec2 delete-vpc --vpc-id $VPC_ID
rm -f /tmp/lab09-*
echo "✅ All lab 09 resources deleted!"
