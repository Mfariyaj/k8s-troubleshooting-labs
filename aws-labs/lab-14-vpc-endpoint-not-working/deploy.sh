#!/bin/bash
set -e
echo "🚀 Lab 14: Networking - S3 VPC endpoint created but still going through NAT: route table not associated"
echo "============================================================"
echo ""
echo "⚠️  Creates VPC/Networking resources"
echo "   Cost: Minimal (VPC resources are mostly free)"
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

echo ""
echo "📋 Scenario: S3 VPC endpoint created but still going through NAT: route table not associated"
echo ""
echo "🔧 This lab requires you to:"
echo "   1. Create the broken networking state (follow guide.md Console steps)"
echo "   2. Observe the connectivity failure"
echo "   3. Fix the misconfiguration"
echo "   4. Verify traffic flows correctly"
echo ""
echo "📖 Open guide.md for detailed Console + CLI instructions"
echo ""
echo "🛠️ Key debugging commands:"
echo "   aws ec2 describe-route-tables --filters Name=vpc-id,Values=<vpc-id>"
echo "   aws ec2 describe-security-groups --group-ids <sg-id>"
echo "   aws ec2 describe-network-acls --filters Name=vpc-id,Values=<vpc-id>"
echo ""
echo "🧹 When done: ./cleanup.sh"
