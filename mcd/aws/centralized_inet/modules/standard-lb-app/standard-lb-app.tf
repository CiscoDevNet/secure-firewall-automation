terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Network Load Balancer

resource "aws_lb" "app-lb" {
  name               = "${var.env_name}-${var.app_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in var.spoke_subnets : subnet.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "${var.env_name}-${var.app_name}-nlb"
    prefix = var.env_name
    app  = var.app_name
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "${var.env_name}-${var.app_name}-target-group"
  port     = var.app_service
  protocol = var.app_protocol
  vpc_id   = var.spoke_vpc_id
  tags = {
    Name    = "${var.env_name}-${var.app_name}-tg"
    prefix = var.env_name
    app  = var.app_name
  }
}

# Target Group Attach
resource "aws_lb_target_group_attachment" "app" {
  count = length(var.aws_availability_zones)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 8080
}

# LB Listener

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = var.app_service
  protocol          = var.app_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
  tags = {
    Name    = "${var.env_name}-${var.app_name}-nlb-listener"
    prefix = var.env_name
    app  = var.app_name
  }
}

# Docker Image that app will be deployed on

data "aws_ami" "ami_docker" {
  most_recent = true
  #owners      = ["null"]
  filter {
    name   = "name"
    values = [var.instance_image]
  }
  filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
  tags = {
    Name = var.instance_image
  }
}

# EC2 Instances

resource "aws_instance" "app" {
  count         = length(var.aws_availability_zones)
  ami           = data.aws_ami.ami_docker.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_pair
  subnet_id     = var.spoke_subnets[count.index].id
  vpc_security_group_ids = [
    aws_security_group.app-sg.id
  ]
  user_data      = var.user_data
  user_data_replace_on_change = true
  tags = {
    Name    = "${var.env_name}-${var.app_name}-${count.index + 1}"
    prefix = var.env_name
    app  = var.app_name
  }
}

resource "aws_security_group" "app-sg" {
  vpc_id = var.spoke_vpc_id
  name   = "${var.env_name}-${var.app_name}-sg"
  tags = {
    Name    = "${var.env_name}-${var.app_name}-sg"
    prefix = var.env_name
    app  = var.app_name
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
