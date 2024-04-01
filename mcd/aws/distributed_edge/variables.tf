variable "env_name" {
  type = string
}

#variable "app_name" {
#  type = string
#}

variable "aws_account" {
  type = string
}

variable "aws_access_key" {
  type = string
  sensitive = true
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "ciscomcd_account" {
  type = string
}
variable "gateway_instance_type" {
  type = string
  default = "AWS_M5_LARGE"
}

variable "aws_min_instances" {
  description = "Min number of gateway instances"
  type = number
  default = 1
}

variable "aws_max_instances" {
  description = "Max number of gateway instances"
  type = number
  default = 3
}

variable "aws_iam_role" {
  type = string
}

variable "gateway_image" {
  type = string
  default = "23.08-14"
}

variable "external_ips" {
  description = "IP Addresses for which a Port 22 is opened in the Security Group. By default the current machines IP is added. These are the additional addresses"
  default     = []
  type        = list(string)
}