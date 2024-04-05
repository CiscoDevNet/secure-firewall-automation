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
  count         = length(var.aws_availability_zones)
  ami           = data.aws_ami.ami_docker.id
  instance_type = "t2.medium"
  key_name      = aws_key_pair.public_key.key_name
  subnet_id     = aws_subnet.edge_private_subnet[count.index].id
  vpc_security_group_ids = [
    aws_security_group.data-sg.id
  ]
  user_data      = <<-EOT
  #!/bin/bash
  git clone https://github.com/emcnicholas/demo-kind-yelb.git
  cd demo-kind-yelb/
  sudo docker compose up -d
  docker ps
  EOT
  user_data_replace_on_change = true
  tags = {
    Name   = "${var.env_name}-${count.index + 1}"
    prefix = var.env_name
    app    = "yelb"
  }
}

# Network Load Balancer

resource "aws_lb" "app-lb" {
  name               = "app-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.edge_public_subnet : subnet.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "${var.env_name}-nlb"
    prefix = var.env_name
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = "8080"
  protocol = "TCP"
  vpc_id   = aws_vpc.edge_vpc.id
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
  port             = 8080
}

# LB Listener

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app-lb.arn
  port              = "8080"
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