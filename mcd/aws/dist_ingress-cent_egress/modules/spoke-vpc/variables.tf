variable "env_name" {
  type = string
}
variable "app_name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "transit_gateway_id" {
  type = string
}
variable "aws_availability_zones" {
  type = list(string)
}
variable "egress_service_vpc_id" {
  type = string
}
variable "ssh_key_pair" {
}
variable "ciscomcd_account" {
  type = string
}
variable "gateway_instance_type" {
  type = string
}
variable "gateway_image" {
  type = string
}

variable "app_service_port" {
  type = string
}
variable "aws_iam_role" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "external_ips" {
  type = list(string)
}