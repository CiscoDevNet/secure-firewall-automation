# VPC

## Edge VPC
resource "aws_vpc" "edge_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_name}-vpc"
    prefix = var.env_name
  }
}

# Edge Subnets

## Public Subnets
resource "aws_subnet" "edge_public_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.edge_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.edge_vpc.cidr_block, 8, 1 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-public-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}

## Private Subnets
resource "aws_subnet" "edge_private_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.edge_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.edge_vpc.cidr_block, 8, 21 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-private-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}

## Management Subnets
resource "aws_subnet" "edge_mgmt_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.edge_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.edge_vpc.cidr_block, 8, 31 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-mgmt-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}
