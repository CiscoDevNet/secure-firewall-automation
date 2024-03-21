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
variable "ingress_service_vpc_id" {
  type = string
}