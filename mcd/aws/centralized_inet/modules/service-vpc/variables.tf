variable "env_name" {
  type = string
}
variable "ciscomcd_account" {
  type = string
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