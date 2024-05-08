#locals {
#  FmcIp     = var.create_fmcv ? var.fmc_mgmt_private_ip : var.cdFMC
#  FmcRegKey = var.create_fmcv ? var.ftd_reg_key : cdo_ftd_device.ftd.reg_key
#  FmcNatId  = var.create_fmcv ? var.ftd_nat_id : cdo_ftd_device.ftd.nat_id
#  # If "create_fmcv" is TRUE, use FMCv variables, if FALSE use cdFMC variables.
#  fmc_user = var.create_fmcv ? var.fmc_user : null
#  fmc_pass = var.create_fmcv ? var.fmc_pass : null
#  fmc_host = var.create_fmcv ? var.fmc_public_ip : var.cdFMC
#  is_cdfmc = var.create_fmcv ? false : true
#  cdo_token = var.create_fmcv ? null : var.cdo_token
#  cdfmc_domain_uuid = var.create_fmcv ? null : var.cdfmc_domain_uuid
#
#  # If variable "create_fmcv" is "true" then ftd_mgmt_ip will be private ip address
#  # if variable "create_fmcv" is "false" then ftd_mgmt_ip will be public ip address
#  ftd_mgmt_ip = var.create_fmcv ? var.ftd_mgmt_private_ip : var.ftd_mgmt_public_ip
#}