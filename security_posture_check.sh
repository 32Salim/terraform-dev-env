
#!/bin/bash

REGION=$1

echo "Checking GuardDuty..."
aws guardduty list-detectors --region $REGION

echo "Checking AWS Config..."
aws configservice describe-configuration-recorders --region $REGION

echo "Checking EC2 instances..."
aws ec2 describe-instances --region $REGION --query "Reservations[].Instances[].InstanceId"

echo "Checking Security Groups..."
aws ec2 describe-security-groups --region $REGION --query "SecurityGroups[].GroupName"

echo "Checking NACLs..."
aws ec2 describe-network-acls --region $REGION --query "NetworkAcls[].NetworkAclId"

echo "Checking IAM Identity Center..."
aws sso-admin list-instances --region $REGION

