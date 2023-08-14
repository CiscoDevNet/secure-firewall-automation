##############
# Variables
##############

# Environment

# Env name is tagged on all resources
variable "env_name" {
  default = "NGFW"
}

# AWS
variable "aws_access_key" {
  description = "Pass this value using tfvars file"
  type        = string
  sensitive   = true
}
variable "aws_secret_key" {
  description = "Pass this value using tfvars file"
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

# Secure Firewall

# If creating FMCv in VPC then true, if using cdFMC then false.
variable "create_fmcv" {
  description = "true or false - pass this value using tfvars file"
  type        = bool
}

variable "ftd_pass" {
  description = "FTD and FMC password - pass this value using tfvars file"
  type        = string
  sensitive   = true
}
variable "ftd_reg_key" {
  description = "Key to register to FMC - pass this value using tfvars file"
  type        = string
  sensitive   = true
}
variable "ftd_nat_id" {
  description = "ID to register to FMC - pass this value using tfvars file"
  type        = string
  sensitive   = true
}
variable "cdFMC" {
  description = "FQDN of cdFMC instance - pass this value using tfvars file"
  type        = string
}

# Service VPC
variable "srvc_cidr" {
  default = "10.0.0.0/16"
}
variable "mgmt_subnet" {
  default = "10.0.0.0/24"
}
variable "data_subnet" {
  default = "10.0.1.0/24"
}
variable "ccl_subnet" {
  default = "10.0.2.0/24"
}
variable "ftd_mgmt_private_ip" {
  default = "10.0.0.10"
}
variable "fmc_mgmt_private_ip" {
  default = "10.0.0.50"
}

# App VPC
variable "app_cidr" {
  default = "10.1.0.0/16"
}
variable "gwlbe_subnet" {
  default = "10.1.0.0/24"
}
variable "app_subnet" {
  default = "10.1.1.0/24"
}
variable "app_server" {
  default = "10.1.1.100"
}

locals {
  # FMC IP - If variable "create_fmcv" is true then IP will be
  # private IP of FMCv. If variable is false then cdFMC fqdn.
  fmc_mgmt_ip = var.create_fmcv ? var.fmc_mgmt_private_ip : var.cdFMC
  # FMC URL
  fmc_url = var.create_fmcv ? aws_eip.fmc-mgmt-EIP[0].public_dns : var.cdFMC
}