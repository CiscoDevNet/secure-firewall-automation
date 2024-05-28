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
  default     = "FTDv30"
}

variable "fmc_host" {
  description = "FMC Hostname or IP - pass this value using tfvars file"
  type        = string
}
variable "fmc_user" {
  type        = string
  default     = "admin"
  sensitive   = true
}
variable "fmc_pass" {
  type        = string
  sensitive   = true
}
variable "fmc_reg_key" {
  description = "Key to register to FMC - pass this value using tfvars file"
  type        = string
  sensitive   = true
}
variable "fmc_nat_id" {
  description = "ID to register to FMC - pass this value using tfvars file"
  type        = string
  sensitive   = true
}