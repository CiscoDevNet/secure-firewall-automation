##################
# EC2 Instances
##################

# FTD Resources

# FTD AMI
data "aws_ami" "ftdv" {
  most_recent = true
  owners      = ["679593333241"]
  #include_deprecated = true
  filter {
    name   = "name"
    values = [var.ftd_version]
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

# Create default Access Control Policy
resource "fmc_access_policies" "access_policy" {
  name           = "${var.env_name}-Access-Policy"
  default_action = "block"
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
     "FmcIp": "${var.fmc_host}",
     "FmcRegKey":"${var.fmc_reg_key}",
     "FmcNatId":"${var.fmc_nat_id}",
     "Cluster":{
        "CclSubnetRange":"10.0.2.4 10.0.2.30",
        "ClusterGroupName":"${var.env_name}-cluster",
        "Geneve":"Yes",
        "HealthProbePort":"443"
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
