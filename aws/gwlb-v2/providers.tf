###################################
# Providers
###################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "1.4.8"
    }
  }
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = var.region
}
provider "fmc" {
    fmc_username = var.fmc_user
    fmc_password = var.fmc_pass
    fmc_host = var.fmc_host
    fmc_insecure_skip_verify = true
}