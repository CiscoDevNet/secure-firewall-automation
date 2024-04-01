# Create a UserKeyPair for EC2 instance
resource "tls_private_key" "key_pair" {
  # algorithm = "RSA"
  # rsa_bits  = 4096
  algorithm = "ED25519"
}

# Save the private key on local file
resource "local_file" "this" {
  content         = tls_private_key.key_pair.private_key_openssh
  filename        = "${var.env_name}-private-key.pem"
  file_permission = 0600
}

# Random string for public key name
resource "random_string" "id" {
  length      = 4
  min_numeric = 4
  special     = false
  lower       = true
}

# Save the public key on AWS
resource "aws_key_pair" "public_key" {
  key_name   = "${var.env_name}-${random_string.id.result}-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

# Edge VPC

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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.edge_vpc.id

  tags = {
    Name   = "${var.env_name}-igw"
    prefix = var.env_name
  }
}

# add tags to the default route table
resource "aws_default_route_table" "vpc_default_rtable" {
  default_route_table_id = aws_vpc.edge_vpc.default_route_table_id
  tags = {
    Name   = "${var.env_name}-default-rtable"
    prefix = var.env_name
  }
}

resource "aws_security_group" "data-sg" {
  vpc_id = aws_vpc.edge_vpc.id
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

resource "aws_security_group" "mgmt-sg" {
  name   = "${var.env_name}-mgmt-sg"
  vpc_id = aws_vpc.edge_vpc.id
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

# Policy Rule Set

resource "ciscomcd_policy_rule_set" "egress_policy" {
  name = "${var.env_name}-egress-policy-ruleset"
}

resource "ciscomcd_gateway" "egress_gw" {
  name                    = "${var.env_name}-egress-gw"
  description             = "${var.env_name}-egress-gw"
  csp_account_name        = var.ciscomcd_account
  instance_type           = var.gateway_instance_type
  gateway_image           = var.gateway_image
  gateway_state           = "ACTIVE"
  mode                    = "EDGE"
  security_type           = "EGRESS"
  policy_rule_set_id      = ciscomcd_policy_rule_set.egress_policy.id
  ssh_key_pair            = aws_key_pair.public_key.key_name
  aws_iam_role_firewall   = var.aws_iam_role
  region                  = var.aws_region
  vpc_id                  = aws_vpc.edge_vpc.id
  mgmt_security_group     = aws_security_group.mgmt-sg.id
  datapath_security_group = aws_security_group.data-sg.id
  aws_gateway_lb          = true
  instance_details {
    availability_zone = var.aws_availability_zones[0]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[0].id
    datapath_subnet   = aws_subnet.edge_public_subnet[0].id
  }
  instance_details {
    availability_zone = var.aws_availability_zones[1]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[1].id
    datapath_subnet   = aws_subnet.edge_public_subnet[1].id
  }
}
