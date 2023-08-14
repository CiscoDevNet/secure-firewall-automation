#########################################################
# Routing
#########################################################

# Internet gateway
resource "aws_internet_gateway" "int_gw" {
  vpc_id = aws_vpc.ftd_vpc.id
  tags = {
    Name = "${var.env_name}-IGW"
  }
}

# Outside Route Table
resource "aws_route_table" "ftd_outside_route" {
  vpc_id = aws_vpc.ftd_vpc.id

  tags = {
    Name = "${var.env_name} Outside network Routing table"
  }
}

# Inside Route Table
resource "aws_route_table" "ftd_inside_route" {
  vpc_id = aws_vpc.ftd_vpc.id

  tags = {
    Name = "${var.env_name} Inside network Routing table"
  }
}

# Default Route for Outside Route Table to Internet GW
resource "aws_route" "ext_default_route" {
  route_table_id         = aws_route_table.ftd_outside_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.int_gw.id
}

# Default Route for Inside Route Table to FTD Inside Interface
resource "aws_route" "inside_default_route" {
#  depends_on              = [aws_instance.ftdv]
  route_table_id          = aws_route_table.ftd_inside_route.id
  destination_cidr_block  = "0.0.0.0/0"
  network_interface_id    = aws_network_interface.ftdinside.id
}

# Associate the Outside Subnet to the Outside Route Table
resource "aws_route_table_association" "outside_association" {
  subnet_id      = aws_subnet.outside_subnet.id
  route_table_id = aws_route_table.ftd_outside_route.id
}

# Associate the Mgmt Subnet to the Outside Route Table
resource "aws_route_table_association" "mgmt_association" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.ftd_outside_route.id
}

# Associate the Inside Subnet to the Inside Route Table
resource "aws_route_table_association" "inside_association" {
  subnet_id      = aws_subnet.inside_subnet.id
  route_table_id = aws_route_table.ftd_inside_route.id
}