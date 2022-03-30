terraform {
  required_version = ">= 1.0.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.35.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}


