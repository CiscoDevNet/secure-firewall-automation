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

variable "create_vn" {
  default     = true
  description = "Wheather to create Virtual Network"
}

variable "vn_name" {
  default     = ""
  description = "Existing Virtual Network Name"
}

variable "vn_cidr" {
  default     = "10.0.0.0/16"
  description = "Virtual Network CIDR"
}


variable "subnet_size" {
  default     = 24
  description = "Size of Subnets"
}

variable "source_address" {
  default     = "*"
  description = "Limit the Management access to specific source"
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
  default     =   1
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
  default     = "admin"
  description = "Username for the VM OS"
}

variable "fmc_password" {
  description = "Password for the VM OS"
  sensitive   = true
}

variable "ftd_password" {
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


variable "subnets" {
  default = []
  description = "subnets for FTD interfaces"
}

variable "fmc_count" {
  default = 1
}

variable "create_fmc" {
  default = true
}

variable "fmc_ip"{}
variable "ftd_mgmt_ip" {
  default = []
}

variable "reg_key" {
  type = string
}

variable "fmc_nat_id" {
  type = string
}