################
# Variables
################

variable "env_name" {
  description = "Name of the lab environment"
  type = string
  default = "NGFW-Lab"
}

# AWS Variables

variable "aws_access_key" {
  type = string
  sensitive = true
}
variable "aws_secret_key" {
  type = string
  sensitive = true
}
variable "region" {
  type = string
  default = "us-east-1"
}

variable "aws_az" {
  type = string
  default = "us-east-1a"
}

variable "vpc_cidr" {
  type = string
  default = "172.16.0.0/16"
}

variable "mgmt_subnet" {
  type = string
  default = "172.16.0.0/24"
}

variable "ftd_mgmt_ip" {
  type = string
  default = "172.16.0.10"
}

variable "fmc_mgmt_ip" {
  type = string
  default = "172.16.0.50"
}

variable "outside_subnet" {
  type = string
  default = "172.16.2.0/24"
}

variable "ftd_outside_ip" {
  type = string
  default = "172.16.2.10"
}

variable "inside_subnet" {
  type = string
  default = "172.16.3.0/24"
}

variable "ftd_inside_ip" {
  type = string
  default = "172.16.3.10"
}

variable "diag_subnet" {
  type = string
  default = "172.16.1.0/24"
}

# Secure Firewall Variables

variable "create_fmcv" {
  type = bool
}

variable "FMC_version" {
  type = string
  default = "fmcv-7.3.0"
}

variable "FTD_version" {
  type = string
  default = "ftdv-7.3.0"
}

variable "fmc_user" {
  description = "FMC User ID"
  type = string
  default = "admin"
}

variable "fmc_pass" {
  description = "FMC Password"
  type = string
  sensitive = true
}

variable "ftd_pass" {
  description = "FMC Password"
  type = string
  sensitive = true
}

variable "fmc_insecure_skip_verify" {
    type = bool
    default = true
}

variable "ftd_size" {
  type = string
  default = "c5.xlarge"
}

variable "fmc_size" {
  type = string
  default = "c5.4xlarge"
}

variable "fmc_reg_key" {
  type = string
  default = "cisco"
}

variable "fmc_nat_id" {
  type = string
  default = "abc123"
}

variable "cdFMC" {
  description = "Hostname of cdFMC"
  type = string
  default = ""
}

variable "ftd_performance_tier" {
  default = "FTDv20"
}

#################################################################
# Local Variables
#################################################################
locals {
  # FMC IP - If variable "create_fmcv" is true then IP will be
  # private IP of FMCv. If variable is false then cdFMC fqdn.
  fmc_ip = var.create_fmcv ? var.fmc_mgmt_ip : var.cdFMC
  # FMC URL
  fmc_url = var.create_fmcv ? aws_eip.fmcmgmt-EIP[0].public_dns : var.cdFMC
}