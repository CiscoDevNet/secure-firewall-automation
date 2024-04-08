variable "env_name" {
  type = string
}
variable "ciscomcd_account" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "aws_availability_zones" {
  type = list(string)
}
variable "vpc_cidr" {
  type = string
}
variable "transit_gateway_id" {
  type = string
}
variable "use_nat_gateway" {
  type = bool
}
variable "ingress_egress" {
  type = string
}
variable "gateway_instance_type" {
  type = string
}
variable "aws_min_instances" {
  description = "Min number of gateway instances"
  type = number
}
variable "aws_max_instances" {
  description = "Max number of gateway instances"
  type = number
}
variable "aws_iam_role" {
  type = string
}
variable "gateway_image" {
  type = string
}
variable "ssh_key_pair" {
  type = string
}
variable "aws_gateway_lb" {
  type = bool
}