variable "env_name" {
  type = string
}
variable "spoke_subnets" {
  #type = list(string)
}
variable "instance_types" {
  type = string
}
variable "eks_desired_nodes" {
  type = number
}
variable "eks_max_nodes" {
  type = number
}
variable "eks_min_nodes" {
  type = number
}
variable "aws_account" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "spoke_vpc_id" {}