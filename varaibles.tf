variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet in AZ1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet in AZ2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_az1_cidr" {
  description = "CIDR block for private subnet in AZ1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR block for private subnet in AZ2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "developer_role_name" {
  description = "IAM role name for developers"
  type        = string
  default     = "developer-role"
}

variable "auditor_role_name" {
  description = "IAM role name for read-only auditors"
  type        = string
  default     = "auditor-role"
}

variable "cicd_role_name" {
  description = "IAM role name for GitHub Actions CI/CD"
  type        = string
  default     = "github-actions-cicd-role"
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the CI/CD role"
  type        = string
  default     = "main"
}

variable "identity_center_instance_arn" {
  description = "AWS IAM Identity Center instance ARN"
  type        = string
}

variable "identity_store_id" {
  description = "AWS IAM Identity Center Identity Store ID"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID where permission sets will be assigned"
  type        = string
}

variable "my_ip" {
  description = "Public IP address allowed to SSH into bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "Existing EC2 key pair name for bastion SSH access"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type for private EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "private_key_name" {
  description = "Existing EC2 key pair name for private instance"
  type        = string
}



