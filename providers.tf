terraform {
  cloud {
    organization = "EC2-DEPLOYER-DEV"
    workspaces {
      name = "vpc"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

# Configure AWS provider:

provider "aws" {
  region  = "us-east-1"
#    access_key = var.AWS_ACCESS_KEY_ID
#    secret_key = var.AWS_SECRET_ACCESS_KEY
}