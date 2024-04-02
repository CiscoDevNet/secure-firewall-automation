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
    Name    = "${var.env_name}-${count.index + 1}"
    prefix = var.env_name
  }
}