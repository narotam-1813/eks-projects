provider "aws" {
  region = var.region
  
}

terraform {
  backend "s3" {
    bucket         = "eks-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.7.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}