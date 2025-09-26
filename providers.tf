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
      version = "~> 5.70"
    }
  }
}

# Configure AWS provider:

provider "aws" {
  region = "us-east-1"
}