terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

