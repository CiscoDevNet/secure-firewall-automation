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
    cdo = {
      source = "CiscoDevNet/cdo"
      version = "1.3.1"
    }
  }
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     = var.region
}
provider "fmc" {
  fmc_host = var.cdFMC
  fmc_insecure_skip_verify = "true"
  is_cdfmc  = "true"
  cdo_token = var.cdo_token
  cdfmc_domain_uuid = var.cdfmc_domain_uuid
}
provider "cdo" {
  base_url  = var.cdo_base_url
  api_token = var.cdo_token
}