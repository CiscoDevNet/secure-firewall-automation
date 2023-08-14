#################
# Variables
#################

variable "create_fmcv" {
  type = bool
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

variable "cdFMC" {
  description = "Hostname of cdFMC"
  type = string
  default = ""
}

variable "fmc_insecure_skip_verify" {
    type = bool
    default = true
}

variable "cdo_token" {
  type = string
  sensitive = true
  default = ""
}

variable "cdfmc_domain_uuid" {
  type = string
  default = "e276abec-e0f2-11e3-8169-6d9ed49b625f"
}

variable "ftd_mgmt_ip" {
  description = "Private address of FTD"
  type = string
  default = "172.16.0.10"
}

variable "fmc_public_ip" {
  description = "Public address of FMC"
  type = string
}

variable "ftd_public_ip" {
  description = "Public address of FTD"
  type = string
}

variable "fmc_reg_key" {
  type = string
  default = "cisco"
}

variable "fmc_nat_id" {
  type = string
  default = "abc123"
}

variable "ftd_performance_tier" {
  default = "FTDv20"
}

variable "cdo_region" {
  description = "us, eu, apj"
  default = "us"
}

variable "outside_subnet" {
  type = string
  default = "172.16.2.0/24"
}

variable "inside_subnet" {
  type = string
  default = "172.16.3.0/24"
}

#################################################################
# Local Variables
#################################################################
locals {
  # If "create_fmcv" is TRUE, use FMCv variables, if FALSE use cdFMC variables.
  fmc_user = var.create_fmcv ? var.fmc_user : null
  fmc_pass = var.create_fmcv ? var.fmc_pass : null
  fmc_host = var.create_fmcv ? var.fmc_public_ip : var.cdFMC
  is_cdfmc = var.create_fmcv ? false : true
  cdo_token = var.create_fmcv ? null : var.cdo_token
  cdfmc_domain_uuid = var.create_fmcv ? null : var.cdfmc_domain_uuid

  # If variable "create_fmcv" is "true" then ftd_mgmt_ip will be private ip address
  # if variable "create_fmcv" is "false" then ftd_mgmt_ip will be public ip address
  ftd_mgmt_ip = var.create_fmcv ? var.ftd_mgmt_ip : var.ftd_public_ip


}