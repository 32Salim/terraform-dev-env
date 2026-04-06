resource "azuread_group" "aws_admin" {
  display_name     = "AWS-Admin"
  security_enabled = true
}

resource "azuread_group" "aws_dev" {
  display_name     = "AWS-Dev"
  security_enabled = true
}

resource "azuread_group" "aws_readonly" {
  display_name     = "AWS-ReadOnly"
  security_enabled = true
}

