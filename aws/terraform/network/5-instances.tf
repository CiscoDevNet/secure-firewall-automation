##################################################
# FTDv and FMCv Instances
##################################################

# Query the ASW Marketplace for FTD AMI
data "aws_ami" "ftdv" {
  owners      = ["aws-marketplace"]

 filter {
    name   = "name"
    values = ["${var.FTD_version}*"]
  }

  filter {
    name   = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Query the ASW Marketplace for FMC AMI
data "aws_ami" "fmcv" {
  #count    = var.create_fmcv ? 1 : 0
  owners   = ["aws-marketplace"]

 filter {
    name   = "name"
    values = ["${var.FMC_version}*"]
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

# Deploy FTD Instance in AWS
resource "aws_instance" "ftdv" {
    ami                 = data.aws_ami.ftdv.id
    instance_type       = var.ftd_size
    key_name            = aws_key_pair.public_key.key_name
    availability_zone   = var.aws_az
  # Assign FTD interfaces to AWS interfaces
  network_interface {
    network_interface_id = aws_network_interface.ftdmgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ftddiag.id
    device_index         = 1
  }
   network_interface {
    network_interface_id = aws_network_interface.ftdoutside.id
    device_index         = 2
  }

    network_interface {
    network_interface_id = aws_network_interface.ftdinside.id
    device_index         = 3
  }
  # Bootstrap Hostname, Password and Mgmt Config
  user_data = <<-EOT
  {
   "AdminPassword":"${var.ftd_pass}",
   "Hostname":"FTD1",
   "ManageLocally":"No",
   "FmcIp":"${local.fmc_ip}",
   "FmcRegKey":"${var.fmc_reg_key}",
   "FmcNatId":"${var.fmc_nat_id}"
  }
  EOT

  tags = {
    Name = "${var.env_name}_FTD"
  }
}

# Deploy FMCv Instance in AWS
# (Only created when "create_fmcv" variable is set to TRUE)
resource "aws_instance" "fmcv" {
  count               = var.create_fmcv ? 1 : 0
  ami                 = data.aws_ami.fmcv.id
  instance_type       = var.fmc_size
  key_name            = aws_key_pair.public_key.key_name
  availability_zone   = var.aws_az
  network_interface {
    network_interface_id = aws_network_interface.fmcmgmt[0].id
    device_index         = 0
  }
  user_data = <<-EOT
  {
   "AdminPassword":"${var.fmc_pass}",
   "Hostname":"FMC1"
  }
  EOT

  tags = {
    Name = "${var.env_name}_FMCv"
  }
}

# FTD Mgmt Elastic IP
resource "aws_eip" "ftdmgmt-EIP" {
  depends_on = [aws_internet_gateway.int_gw,aws_instance.ftdv]
  tags = {
    "Name" = "${var.env_name} FTD Management IP"
  }
}

# FTD Outside Elastic IP
resource "aws_eip" "ftdoutside-EIP" {
  #vpc   = true
  depends_on = [aws_internet_gateway.int_gw,aws_instance.ftdv]
  tags = {
    "Name" = "${var.env_name} FTD outside IP"
  }
}

# FMC Mgmt Elastic IP
# (Only created when "create_fmcv" variable is set to TRUE)
resource "aws_eip" "fmcmgmt-EIP" {
  count = var.create_fmcv ? 1 : 0
  #vpc   = true
  depends_on = [aws_internet_gateway.int_gw,aws_instance.ftdv]
  tags = {
    "Name" = "${var.env_name} FMCv Management IP"
  }
}

# Associate FTD Mgmt Interface to External IP
resource "aws_eip_association" "ftd-mgmt-ip-assocation" {
  network_interface_id = aws_network_interface.ftdmgmt.id
  allocation_id        = aws_eip.ftdmgmt-EIP.id
}

# Associate FTD Outside Interface to External IP
resource "aws_eip_association" "ftd-outside-ip-association" {
    network_interface_id = aws_network_interface.ftdoutside.id
    allocation_id        = aws_eip.ftdoutside-EIP.id
}

# Assocaite FMC Management Interface to External IP
# (Only created when "create_fmcv" variable is set to TRUE)
resource "aws_eip_association" "fmc-mgmt-ip-assocation" {
  count                = var.create_fmcv ? 1 : 0
  network_interface_id = aws_network_interface.fmcmgmt[0].id
  allocation_id        = aws_eip.fmcmgmt-EIP[0].id
}

# Create file with FMC and FTD access information

resource "local_file" "lab_info" {
  depends_on = [aws_eip.fmcmgmt-EIP, aws_eip.ftdmgmt-EIP]
    content     = <<-EOT
    FMC URL  = https://${local.fmc_url}
    FTD SSH  = ssh -i "${local_file.this.filename}" admin@${aws_eip.ftdmgmt-EIP.public_dns}
    EOT

    filename = "${path.module}/lab_info.txt"
}