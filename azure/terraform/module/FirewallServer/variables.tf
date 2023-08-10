variable "location" {
  default     = "Central India"
  description = "Azure region"
}

variable "prefix" {
  default     = "cisco-FTDv"
  description = "Prefix to prepend resource names"
}

variable "create_rg" {
  default     = true
  description = "Wheather to create Resource Group"
}

variable "rg_name" {
  default     = "cisco-FTDv-RG"
  description = "Azure Resource Group"
}

variable "azs" {
  default = [
    "1",
    "2",
    "3"
  ]
  description = "Azure Availability Zones"
}

variable "instances" {
  default     = 2
  description = "Number of FTDv instances"
}

variable "vm_size" {
  default     = "Standard_D3_v2"
  description = "Size of the VM for ASAv"
}

variable "instancename" {
  default     = "FTDv"
  description = "FTDv instance Name"
}

variable "username" {
  default     = "cisco"
  description = "Username for the VM OS"
}

variable "fmc_password" {
  default     = "Cisco@123"
  description = "Password for the VM OS"
  sensitive   = true
}

variable "fmc_image_version" {
  default     = "73069.0.0"
  description = "Version of the FTDv"
}

variable "ftd_image_version" {
  default     = "73069.0.0"
  description = "Version of the FTDv"
}

variable "ftd_password" {
  default     = "Cisco@123"
  description = "Password for the VM OS"
  sensitive   = true
}

variable "create_fmc" {
  default = true
}

variable "ftd_mgmt_interface" {}
variable "ftd_inside_interface" {}
variable "ftd_outside_interface" {}
variable "ftd_diag_interface" {}
variable "fmc_mgmt_interface" {}
variable "keypair" {}
variable "fmc_ip" {}
variable "reg_key" {}
variable "fmc_nat_id" {}