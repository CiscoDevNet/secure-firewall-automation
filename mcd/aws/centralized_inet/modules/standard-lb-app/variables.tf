variable "env_name" {
  type = string
}
variable "app_name" {
  type = string
}
variable "app_service" {
  type = number
}
variable "app_protocol" {
  type = string
}
variable "spoke_subnets" {
  #type = list(string)
}
variable "spoke_vpc_id" {
  type = string
}
variable "aws_availability_zones" {
  type = list(string)
}
variable "instance_image" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "ssh_key_pair" {
  type = string
}
variable "user_data" {
  type = string
}