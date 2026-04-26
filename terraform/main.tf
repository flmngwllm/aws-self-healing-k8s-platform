terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "self-heal-terraform-state"
    key            = "self-heal-platform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "self-heal-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.REGION
}


