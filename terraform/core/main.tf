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


data "aws_eks_cluster" "self_heal_cluster" {
  name = aws_eks_cluster.self_heal_cluster.name
}

data "aws_eks_cluster_auth" "self_heal_cluster" {
  name = aws_eks_cluster.self_heal_cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.self_heal_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.self_heal_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.self_heal_cluster.token
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

