terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "0.2.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Spoke VPC

resource "aws_vpc" "spoke_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_name}-${var.app_name}-vpc"
    prefix = var.env_name
    app  = var.app_name
  }
}

# Spoke VPC route table

resource "aws_route_table" "spoke_route_table" {
  depends_on = [ciscomcd_spoke_vpc.spoke_to_egress, ciscomcd_spoke_vpc.spoke_to_ingress]
  vpc_id = aws_vpc.spoke_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${var.env_name}-${var.app_name}-route-table"
    prefix = var.env_name
    app  = var.app_name
  }
}

# Spoke Subnets

resource "aws_subnet" "spoke_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.spoke_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.spoke_vpc.cidr_block, 8, 1 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-${var.app_name}-subnet-${count.index + 1}"
    prefix = var.env_name
    app  = var.app_name
    #"kubernetes.io/role/internal-elb" = 1
  }
}

# Spoke Route Association

resource "aws_route_table_association" "spoke_rt_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.spoke_subnet[count.index].id
  route_table_id = aws_route_table.spoke_route_table.id
}

# Spoke VPC Attach to Egress Service VPC via TGW

resource "ciscomcd_spoke_vpc" "spoke_to_egress" {
  service_vpc_id = var.egress_service_vpc_id
  spoke_vpc_id   = aws_vpc.spoke_vpc.id
}

# Spoke VPC Attach to Ingress Service VPC via TGW

resource "ciscomcd_spoke_vpc" "spoke_to_ingress" {
  service_vpc_id = var.ingress_service_vpc_id
  spoke_vpc_id   = aws_vpc.spoke_vpc.id
}