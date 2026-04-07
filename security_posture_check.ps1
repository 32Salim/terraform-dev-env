
param (
    [string]$Region = "us-east-1"
)

Write-Host "=== AWS Security Posture Check ===" -ForegroundColor Cyan

Write-Host "`nChecking GuardDuty..." -ForegroundColor Yellow
aws guardduty list-detectors --region $Region

Write-Host "`nChecking AWS Config..." -ForegroundColor Yellow
aws configservice describe-configuration-recorders --region $Region

Write-Host "`nChecking EC2 Instances..." -ForegroundColor Yellow
aws ec2 describe-instances --region $Region --query "Reservations[].Instances[].InstanceId"

Write-Host "`nChecking Security Groups..." -ForegroundColor Yellow
aws ec2 describe-security-groups --region $Region --query "SecurityGroups[].GroupName"

Write-Host "`nChecking Network ACLs..." -ForegroundColor Yellow
aws ec2 describe-network-acls --region $Region --query "NetworkAcls[].NetworkAclId"

Write-Host "`nChecking IAM Identity Center..." -ForegroundColor Yellow
aws sso-admin list-instances --region $Region


