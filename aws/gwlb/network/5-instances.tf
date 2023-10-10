##################
# EC2 Instances
##################

# FTD Resources

# FTD AMI
data "aws_ami" "ftdv" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["ftdv-7.3*"]
  }
  filter {
    name   = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }
}

# FTD Management interface
resource "aws_network_interface" "ftd_management" {
  description     = "ftd_mgmt_if"
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  private_ips   = [var.ftd_mgmt_private_ip]
  tags = {
    Name = "${var.env_name} Service FTD Mgmt"
  }
}

# FTD Diagnostic interface
resource "aws_network_interface" "ftd_diagnostic" {
  description     = "ftd_diag_if"
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} Service FTD Diag"
  }
}

# FTD Data interface
resource "aws_network_interface" "ftd_data" {
  description       = "ftd_data_if"
  subnet_id         = aws_subnet.data_subnet.id
  security_groups   = [aws_security_group.allow_all.id]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} Service FTD Data"
  }
}

# CCL interfaces
resource "aws_network_interface" "ftd_ccl" {
  description       = "ftd_ccl_if"
  subnet_id         = aws_subnet.ccl_subnet.id
  security_groups   = [aws_security_group.allow_all.id]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} Service FTD CCL"
  }
}

# FTD Firewalls
resource "aws_instance" "ftd" {
  ami                         = data.aws_ami.ftdv.id
  instance_type               = "c5.xlarge"
  key_name                    = aws_key_pair.public_key.key_name
  user_data_replace_on_change = true
  user_data                   = <<-EOT
  {
     "AdminPassword":"${var.ftd_pass}",
     "Hostname":"${var.env_name}-FTDv",
     "ManageLocally":"No",
     "FmcIp": "${local.fmc_mgmt_ip}",
     "FmcRegKey":"${var.ftd_reg_key}",
     "FmcNatId":"${var.ftd_nat_id}",
     "Cluster":{
        "CclSubnetRange":"10.0.2.4 10.0.2.30",
        "ClusterGroupName":"${var.env_name}-cluster",
        "Geneve":"Yes",
        "HealthProbePort":"7777"
     }
  }
  EOT

  network_interface {
    network_interface_id = aws_network_interface.ftd_management.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_diagnostic.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_data.id
    device_index         = 2
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_ccl.id
    device_index         = 3
  }
  tags = {
    Name = "${var.env_name} FTD"
  }
}

resource "aws_eip" "ftd-mgmt-EIP" {
  #vpc   = true
  depends_on = [aws_internet_gateway.mgmt_igw,aws_instance.ftd]
  tags = {
    Name = "${var.env_name} Service FTD Mgmt EIP"
    app  = "service"
  }
}

resource "aws_eip_association" "ftd-mgmt-ip-assocation" {
  network_interface_id = aws_network_interface.ftd_management.id
  allocation_id        = aws_eip.ftd-mgmt-EIP.id
}

# FMCv Resources

# FMC AMI
data "aws_ami" "fmcv" {
  count    = var.create_fmcv ? 1 : 0
  most_recent = true
  owners   = ["aws-marketplace"]

 filter {
    name   = "name"
    values = ["fmcv-7.3*"]
  }

  filter {
    name   = "product-code"
    values = ["bhx85r4r91ls2uwl69ajm9v1b"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# FMCv Mgmt Interface
resource "aws_network_interface" "fmc_management" {
  depends_on      = [aws_subnet.mgmt_subnet]
  count           = var.create_fmcv ? 1 : 0
  description     = "fmc-mgmt"
  subnet_id       = aws_subnet.mgmt_subnet.id
  private_ips     = [var.fmc_mgmt_private_ip]
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} FMCv Mgmt"
  }
}
# Deploy FMCv Instance in AWS
resource "aws_instance" "fmcv" {
  count               = var.create_fmcv ? 1 : 0
  ami                 = data.aws_ami.fmcv[0].id
  instance_type       = "c5.4xlarge"
  key_name            = aws_key_pair.public_key.key_name
  availability_zone   = var.aws_az
  network_interface {
    network_interface_id = aws_network_interface.fmc_management[0].id
    device_index         = 0
  }
  user_data = <<-EOT
  {
   "AdminPassword":"${var.ftd_pass}",
   "Hostname":"${var.env_name}-FMCv"
  }
  EOT

  tags = {
    Name = "${var.env_name}_FMCv"
  }
}

# FMC Mgmt Elastic IP
resource "aws_eip" "fmc-mgmt-EIP" {
  depends_on = [aws_internet_gateway.mgmt_igw,aws_instance.fmcv]
  count      = var.create_fmcv ? 1 : 0
  tags = {
    "Name" = "${var.env_name} FMCv Management IP"
  }
}


# Assocaite FMC Management Interface to External IP
resource "aws_eip_association" "fmc-mgmt-ip-assocation" {
  count                = var.create_fmcv ? 1 : 0
  network_interface_id = aws_network_interface.fmc_management[0].id
  allocation_id        = aws_eip.fmc-mgmt-EIP[0].id
}

# App Resources

# App AMI
data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Instances in App VPC
resource "aws_instance" "app" {
  ami           = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.public_key.key_name
  subnet_id     = aws_subnet.app_subnet.id
  private_ip    = var.app_server
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.app_allow_all.id
  ]
  tags = {
    Name    = "${var.env_name} App Server"
  }
}

resource "local_file" "lab_info" {
  depends_on = [aws_eip.fmc-mgmt-EIP, aws_eip.ftd-mgmt-EIP, aws_instance.app]
    content     = <<-EOT
    FMC URL  = https://${local.fmc_url}
    FTD SSH  = ssh -i "${local_file.this.filename}" admin@${aws_eip.ftd-mgmt-EIP.public_dns}
    APP SSH  = ssh -i "${local_file.this.filename}" ec2-user@${aws_instance.app.public_dns}
    EOT

    filename = "${path.module}/lab_info.txt"
}