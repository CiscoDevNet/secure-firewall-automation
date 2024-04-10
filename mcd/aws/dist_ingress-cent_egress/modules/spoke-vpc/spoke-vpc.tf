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
    Name = "${var.env_name}-vpc"
    prefix = var.env_name
  }
}

# Spoke VPC internal route table

resource "aws_route_table" "internal_route_table" {
  depends_on = [ciscomcd_spoke_vpc.spoke_to_egress]
  vpc_id = aws_vpc.spoke_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${var.env_name}-route-table"
    prefix = var.env_name
  }
}

# Spoke Internal Subnets

resource "aws_subnet" "internal_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.spoke_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.spoke_vpc.cidr_block, 8, 1 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-internal-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}

# Spoke Internal Route Association

resource "aws_route_table_association" "spoke_rt_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.internal_subnet[count.index].id
  route_table_id = aws_route_table.internal_route_table.id
}

# Spoke VPC Attach to Egress Service VPC via TGW

resource "ciscomcd_spoke_vpc" "spoke_to_egress" {
  service_vpc_id = var.egress_service_vpc_id
  spoke_vpc_id   = aws_vpc.spoke_vpc.id
}

######

## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.spoke_vpc.id

  tags = {
    Name   = "${var.env_name}-igw"
    prefix = var.env_name
  }
}

## Public Default Route
## Default Route Table for the Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.spoke_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Spoke Public Subnets

resource "aws_subnet" "public_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.spoke_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.spoke_vpc.cidr_block, 8, 11 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-public-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}


## Associate the Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Spoke Mgmt Subnets
## Management Subnets
resource "aws_subnet" "edge_mgmt_subnet" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.spoke_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.spoke_vpc.cidr_block, 8, 21 + count.index)
  availability_zone = var.aws_availability_zones[count.index]
  tags = {
    Name    = "${var.env_name}-mgmt-subnet-${count.index + 1}"
    prefix = var.env_name
  }
}

resource "aws_route_table_association" "mgmt_subnet_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.edge_mgmt_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

#####
# Policy Rule Set

resource "ciscomcd_policy_rule_set" "ingress_policy" {
  name = "${var.env_name}-ingress-policy-ruleset"
}

# Cisco Multicloud Defense Ingress Gateway

## Deploys Ingress Gateways and Network Load Balancer in Public Subnets.
## Used to inspect inbound traffic to the applications.
resource "ciscomcd_gateway" "ingress-gw" {
  name                    = "${var.env_name}-ingress-gw"
  description             = "${var.env_name}-ingress-gw"
  csp_account_name        = var.ciscomcd_account
  instance_type           = var.gateway_instance_type
  gateway_image           = var.gateway_image
  gateway_state           = "ACTIVE"
  mode                    = "EDGE"
  security_type           = "INGRESS"
  policy_rule_set_id      = ciscomcd_policy_rule_set.ingress_policy.id
  ssh_key_pair            = var.ssh_key_pair
  aws_iam_role_firewall   = var.aws_iam_role
  region                  = var.aws_region
  vpc_id                  = aws_vpc.spoke_vpc.id
  mgmt_security_group     = aws_security_group.mgmt-sg.id
  datapath_security_group = aws_security_group.data-sg.id
  instance_details {
    availability_zone = var.aws_availability_zones[0]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[0].id
    datapath_subnet   = aws_subnet.public_subnet[0].id
  }
  instance_details {
    availability_zone = var.aws_availability_zones[1]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[1].id
    datapath_subnet   = aws_subnet.public_subnet[1].id
  }
  settings {
    name = "gateway.snat_mode"
    value = "1"
  }
}

#####
# Yelb App

# Docker Image that app will be deployed on

data "aws_ami" "ami_docker" {
  most_recent = true
  #owners      = ["null"]
  filter {
    name   = "name"
    values = ["DockerCompose-Ubuntu-*"]
  }
  filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
  tags = {
    Name = var.env_name
  }
}

# EC2 Instances

resource "aws_instance" "app" {
  depends_on = [ciscomcd_spoke_vpc.spoke_to_egress]
  count         = length(var.aws_availability_zones)
  ami           = data.aws_ami.ami_docker.id
  instance_type = "t2.medium"
  key_name      = var.ssh_key_pair
  subnet_id     = aws_subnet.internal_subnet[count.index].id
  vpc_security_group_ids = [
    aws_security_group.data-sg.id
  ]
  user_data      = <<-EOT
  #!/bin/bash
  echo "Building Yelb App"
  git clone https://github.com/emcnicholas/demo-kind-yelb.git
  cd demo-kind-yelb/
  sudo docker compose up -d
  docker ps
  EOT
  user_data_replace_on_change = true
  tags = {
    Name   = "${var.env_name}-${count.index + 1}"
    prefix = var.env_name
    app    = var.app_name
  }
}

# Network Load Balancer

resource "aws_lb" "app-lb" {
  name               = "app-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "${var.env_name}-nlb"
    prefix = var.env_name
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = var.app_service_port
  protocol = "TCP"
  vpc_id   = aws_vpc.spoke_vpc.id
  tags = {
    Name    = "${var.env_name}-tg"
    prefix = var.env_name
  }
}

# Target Group Attach
resource "aws_lb_target_group_attachment" "app" {
  count = length(var.aws_availability_zones)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = var.app_service_port
}

# LB Listener

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = var.app_service_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
  tags = {
    Name    = "${var.env_name}-nlb-listener"
    prefix = var.env_name
  }
}

# Security Groups

## Data Security Group
## Data Plane Security Group with allows All
resource "aws_security_group" "data-sg" {
  vpc_id = aws_vpc.spoke_vpc.id
  name   = "${var.env_name}-data-sg"
  tags = {
    Name    = "${var.env_name}-data-sg"
    prefix = var.env_name
  }
  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      description      = "Allow all inbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

## Mgmt Security Group
## Mgmt Security Group with allows HTTP, HTTPS, and SSH
resource "aws_security_group" "mgmt-sg" {
  name   = "${var.env_name}-mgmt-sg"
  vpc_id = aws_vpc.spoke_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.external_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name   = "${var.env_name}-mgmt-sg"
    prefix = var.env_name
  }
}
