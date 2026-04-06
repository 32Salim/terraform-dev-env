data "aws_identitystore_user" "admin_user" {
  identity_store_id = var.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "leolim09@yahoo.com"
    }
  }
}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess-PS"
  description      = "Administrator access for AWS users"
  instance_arn     = var.identity_center_instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_policy" {
  instance_arn       = var.identity_center_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

resource "aws_ssoadmin_account_assignment" "admin_assignment" {
  instance_arn       = var.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_type = "USER"
  principal_id   = data.aws_identitystore_user.admin_user.user_id

  target_id   = var.aws_account_id
  target_type = "AWS_ACCOUNT"
}

