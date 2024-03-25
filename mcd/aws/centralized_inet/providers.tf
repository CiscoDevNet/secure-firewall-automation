# Provider Versions

terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "0.2.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.26.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}

# Cisco Multicloud Defense Provider - API JSON file must be added to Infrastructure directory.

provider "ciscomcd" {
  api_key_file = file("valtix_api_key_file.json")
}

# AWS Provider - AWS Key must be passed using environment variables or tfvars file.

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Kubernetes Provider - This data is retreived from the EKS Cluster

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = "${var.env_name}-cluster"
}

provider "kubernetes" {
  host                   = module.eks-cluster.eks-cluster-endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.eks-cluster-certificate_authority)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  #config_path            = "~/.kube/config"
}

provider "kubectl" {
  host                   = module.eks-cluster.eks-cluster-endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.eks-cluster-certificate_authority)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
  #config_path             = "~/.kube/config"
}

provider "helm" {
  kubernetes {
  host                   = module.eks-cluster.eks-cluster-endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.eks-cluster-certificate_authority)
  token                  = data.aws_eks_cluster_auth.eks_cluster_auth.token
    #config_path = "~/.kube/config"
  }
}