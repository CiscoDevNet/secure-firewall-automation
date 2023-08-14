######################################
# VPCs
######################################

# VPC
resource "aws_vpc" "ftd_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env_name}-vpc"
  }
}

# Management Subnet
resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.mgmt_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name}-mgt-subnet"
  }
}

# Diag Subnet
resource "aws_subnet" "diag_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.diag_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name}-diag-subnet"
  }
}

# Outside Subnet
resource "aws_subnet" "outside_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.outside_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name}-outside-subnet"
  }
}

# Inside Subnet
resource "aws_subnet" "inside_subnet" {
  vpc_id            = aws_vpc.ftd_vpc.id
  cidr_block        = var.inside_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name}-inside-subnet"
  }
}