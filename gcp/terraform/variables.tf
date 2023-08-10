############################
#  Provider Configuration  #
############################
variable "project_services" {
  type = list(string)

  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]

  description = "List of services to enable on the project where Vault will run. These services are required in order for this Vault setup to function."
}
variable "project_id" {
  type        = string
  description = "The project ID to host the network in"
}

variable "region" {
  type        = string
  description = "The region"
  default = "us-west1"
}



############################
#  VM Configuration        #
############################

variable "num_instances" {
  description = "Number of instances to create. This value is ignored if static_ips is provided."
  type        = number
  default     = 1
}
variable "vm_zones" {
  type        = list(string)
  description = "The zones of vm instances"
  default = [ "us-west1-a"]
}
variable "vm_machine_type" {
  type        = string
  description = "machine type for appliance"
  default     = "c2-standard-8"
}

variable "vm_instance_labels" {
  type    = map(string)
  default = {
  firewall    = "ftd"
  environment = "dev"
}

  description = "Labels to apply to the vm instances."
}

variable "vm_instance_tags" {
  type    = list(string)
  default = []

  description = "Additional tags to apply to the instances, please note the service account is used as much as possible as best practice"
}

variable "cisco_product_version" {
  type        = string
  description = "cisco product version"
  default     = "cisco-ftdv-7-0-0-94"
}


variable "admin_password" {
  type        = string
  description = "password for admin"
  sensitive   = true
}

variable "ftd_hostname" {
  default     = "ftd"
  description = "FTD hostname"
}
variable "fmc_hostname" {
  default     = "fmc"
  description = "FMC hostname"
}

variable "day_0_config_ftd" {
  type        = string
  description = "Render a startup script with a template."
  default     = "startup_file.json"
}
variable "day_0_config_fmc" {
  type        = string
  description = "Render a startup script for fmc with a template."
  default     = "fmc.txt"
}

variable "admin_ssh_pub_key" {
  type        = string
  description = "ssh public key for admin"
}

############################
#  Network Configuration   #
############################
variable "networks" {
  type        = list(object({ name = string, cidr = string, appliance_ip = list(string), external_ip = bool }))
  description = "a list of VPC network info"
  default     = [
  {
    name         = "vpc-outside"
    cidr         = "10.10.0.0/24"
    appliance_ip = ["10.10.0.10"]
    external_ip  = true
  },
  {
    name         = "vpc-inside"
    cidr         = "10.10.1.0/24"
    appliance_ip = ["10.10.1.10"]
    external_ip  = false
  },
  {
    name         = "vpc-mgmt"
    cidr         = "10.10.2.0/24"
    appliance_ip = ["10.10.2.10"]
    external_ip  = true
  },
  {
    name         = "vpc-diag"
    cidr         = "10.10.3.0/24"
    appliance_ip = ["10.10.3.10"]
    external_ip  = false
  },
  {
    name         = "vpc-dmz"
    cidr         = "10.10.4.0/24"
    appliance_ip = ["10.10.4.10"]
    external_ip  = false
  }
]
}
variable "application_network" {
  type        = list(object({ name = string, cidr = string, appliance_ip = list(string), external_ip = bool }))
  description = "a list of application network info"
  default     = []
}
variable "mgmt_network" {
  type        = string
  description = "management network name"
  default     = "vpc-mgmt"
}

variable "outside_network" {
  type        = string
  description = "outside network name"
  default     = "vpc-outside"
}

variable "inside_network" {
  type        = string
  description = "inside network name"
  default     = "vpc-inside"
}

variable "dmz_network" {
  type        = string
  description = "dmz network name"
  default     = "vpc-dmz"
}

variable "diag_network" {
  type        = string
  description = "diag network name"
  default     = "vpc-diag"
}
variable "bastion_network" {
  type        = string
  description = "bastion network name"
  default     = "bastion_network"
}
variable "app_network" {
  type        = string
  description = "Application network name"
  default     = "app_network"
}
variable "custom_route_tag" {
  type        = string
  description = "tag for custom route"
  default     = "cisco-ftd"
}

variable "appliance_ips_fmc" {
  type        = list(string)
  default     = ["10.10.2.20"]
  description = "internal IP addresses for cisco appliance"
}
variable "network_project_id" {
  type        = string
  description = "The project ID of the shared VPC's host (for shared vpc support)"
  default     = ""
}
variable "boot_disk_size" {
  description = "Root disk size in GB"
  default     = "250"
}

variable "boot_disk_type" {
  description = "The GCE boot disk type.Set to pd-standard (for PD HDD)."
  default     = "pd-ssd"
}
