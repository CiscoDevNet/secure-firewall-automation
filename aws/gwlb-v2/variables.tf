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
#variable "ftd_mgmt_public_ip" {
#  description = "Public address of FTD"
#  type = string
#}
#variable "fmc_mgmt_private_ip" {
#  default = "10.0.0.50"
#}

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

# Cisco Secure Firewall

# Firewall Management
# If creating FMCv in VPC then true, if using cdFMC then false.
#variable "create_fmcv" {
#  description = "true or false - pass this value using tfvars file"
#  type        = bool
#}
#variable "fmc_user" {
#  type      = string
#  sensitive = true
#  default   = "admin"
#}
#variable "fmc_pass" {
#  type      = string
#  sensitive = true
#}
#variable "fmc_public_ip" {
#  type = string
#  default = ""
#}

# Cisco Defense Orchestrator
variable "cdo_token" {
  type        = string
  sensitive   = true
}
variable "cdo_base_url" {
  type = string
  default = "https://www.defenseorchestrator.com"
}
variable "cdfmc_domain_uuid" {
  type        = string
  default     = "e276abec-e0f2-11e3-8169-6d9ed49b625f"
}
variable "cdFMC" {
  description = "FQDN of cdFMC instance - pass this value using tfvars file"
  type        = string
}


# Firepower Threat Defense
variable "ftd_version" {
  type        = string
  default     = "ftdv-7.2*"
}
variable "ftd_pass" {
  type        = string
  sensitive   = true
}
variable "ftd_performance_tier" {
  type        = string
  default     = "FTDv20"
}
#variable "ftd_reg_key" {
#  description = "Key to register to FMC - pass this value using tfvars file"
#  type        = string
#  sensitive   = true
#}
#variable "ftd_nat_id" {
#  description = "ID to register to FMC - pass this value using tfvars file"
#  type        = string
#  sensitive   = true
#}