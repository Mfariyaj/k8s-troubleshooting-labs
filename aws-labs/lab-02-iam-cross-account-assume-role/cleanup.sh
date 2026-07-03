#!/bin/bash
ROLE_NAME="lab02-cross-account-role"
aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess 2>/dev/null
aws iam delete-role --role-name $ROLE_NAME 2>/dev/null
echo "✅ Lab 02 cleaned up"
