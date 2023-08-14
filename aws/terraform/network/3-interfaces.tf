################################################
# AWS Interface and IP address assignments
################################################

# FTD Mgmt Interface
resource "aws_network_interface" "ftdmgmt" {
  description   = "ftd1-mgmt"
  subnet_id     = aws_subnet.mgmt_subnet.id
  private_ips   = [var.ftd_mgmt_ip]
  tags = {
    Name = "${var.env_name} FTD Mgmt"
  }
}

# FTD Diag Interface
resource "aws_network_interface" "ftddiag" {
  description = "ftd-diag"
  subnet_id   = aws_subnet.diag_subnet.id
  tags = {
    Name = "${var.env_name} FTD Diag"
  }
}

# FTD Outside Interface
resource "aws_network_interface" "ftdoutside" {
  description = "ftd1-outside"
  subnet_id   = aws_subnet.outside_subnet.id
  private_ips = [var.ftd_outside_ip]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} FTD Outside"
  }
}

# FTD Inside Interface
resource "aws_network_interface" "ftdinside" {
  description = "ftd01-inside"
  subnet_id   = aws_subnet.inside_subnet.id
  private_ips = [var.ftd_inside_ip]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} FTD Inside"
  }
}

# FMCv Mgmt Interface
# (Only created when "create_fmcv" variable is set to TRUE)
resource "aws_network_interface" "fmcmgmt" {
  count         = var.create_fmcv ? 1 : 0
  depends_on    = [aws_subnet.mgmt_subnet]
  description   = "ftd-mgmt"
  subnet_id     = aws_subnet.mgmt_subnet.id
  private_ips   = [var.fmc_mgmt_ip]
  tags = {
    Name = "${var.env_name} FMC Mgmt"
  }
}

# Attach Security Group to FTD Mgmt Interface
resource "aws_network_interface_sg_attachment" "ftd_mgmt_attachment" {
  depends_on           = [aws_network_interface.ftdmgmt]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.ftdmgmt.id
}

# Attach Security Group to FTD Outside Interface
resource "aws_network_interface_sg_attachment" "ftd_outside_attachment" {
  depends_on           = [aws_network_interface.ftdoutside]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.ftdoutside.id
}

# Attach Security Group to FTD Inside Interface
resource "aws_network_interface_sg_attachment" "ftd_inside_attachment" {
  depends_on           = [aws_network_interface.ftdinside]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.ftdinside.id
}

# Attach Security Group to FMC Management Interface
resource "aws_network_interface_sg_attachment" "fmc_mgmt_attachment" {
  count                = var.create_fmcv ? 1 : 0
  depends_on           = [aws_network_interface.fmcmgmt]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.fmcmgmt[0].id
}