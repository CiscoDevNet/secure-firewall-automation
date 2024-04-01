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

