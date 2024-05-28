####################
# VPCs
####################

# Service VPC
resource "aws_vpc" "srvc_vpc" {
  cidr_block           = var.srvc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.env_name} Service VPC"
  }
}

# Service Subnets
resource "aws_subnet" "mgmt_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.mgmt_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name} Service Mgmt Subnet"
  }
}
resource "aws_subnet" "data_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.data_subnet
  availability_zone = var.aws_az
  tags = {
    Name = "${var.env_name} Service Data Subnet"
  }
}
resource "aws_subnet" "ccl_subnet" {
  vpc_id            = aws_vpc.srvc_vpc.id
  cidr_block        = var.ccl_subnet
  availability_zone = var.aws_az
  tags              = {
    Name = "${var.env_name} Service CCL Subnet"
  }
}
# Service Mgmt IGW
resource "aws_internet_gateway" "mgmt_igw" {
  vpc_id = aws_vpc.srvc_vpc.id
  tags = {
    Name = "${var.env_name} Service Mgmt-IGW"
  }
}

# Mgmt Route Table
resource "aws_route_table" "mgmt_route_table" {
  vpc_id = aws_vpc.srvc_vpc.id
  tags = {
    Name = "${var.env_name} Service Mgmt Route Table"
  }
}

# Mgmt Default Route Routes
resource "aws_route" "mgmt_default_route" {
  depends_on = [aws_internet_gateway.mgmt_igw]
  route_table_id         = aws_route_table.mgmt_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mgmt_igw.id
}

# Mgmt Route Associations
resource "aws_route_table_association" "mgmt_association" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.mgmt_route_table.id
}