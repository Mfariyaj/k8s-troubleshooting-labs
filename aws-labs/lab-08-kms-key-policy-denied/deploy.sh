#!/bin/bash
set -e
echo "🚀 Lab 08: KMS key policy not granting encrypt/decrypt to the right principal"
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
echo "KMS key policy not granting encrypt/decrypt to the right principal"
echo ""
echo "❌ Run these commands to see the error:"
echo "   aws sts get-caller-identity"
echo "   (Follow the guide.md for specific broken commands)"
echo ""
echo "🔍 YOUR TASK: Fix the IAM configuration"
echo "   Check guide.md for Console + CLI steps"
echo ""
echo "🧹 When done: ./cleanup.sh"
