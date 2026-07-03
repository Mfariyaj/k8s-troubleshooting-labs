#!/bin/bash
set -e
echo "🚀 Lab 06: Condition keys (aws:SourceIp, aws:RequestedRegion) blocking valid requests"
echo "============================================================"
echo ""
echo "⚠️  Creates IAM resources in your account"
echo "   Cost: FREE"
read -p "Continue? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
echo ""
echo "📋 Your Account: $ACCOUNT_ID"
echo ""
echo "Condition keys (aws:SourceIp, aws:RequestedRegion) blocking valid requests"
echo ""
echo "❌ Run these commands to see the error:"
echo "   aws sts get-caller-identity"
echo "   (Follow the guide.md for specific broken commands)"
echo ""
echo "🔍 YOUR TASK: Fix the IAM configuration"
echo "   Check guide.md for Console + CLI steps"
echo ""
echo "🧹 When done: ./cleanup.sh"
