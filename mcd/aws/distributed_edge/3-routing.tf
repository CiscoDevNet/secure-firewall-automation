# Routing

## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.edge_vpc.id

  tags = {
    Name   = "${var.env_name}-igw"
    prefix = var.env_name
  }
}

## Public Default Route
## Default Route Table for the Public and Mgmt Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.edge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
## Associate the Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.edge_public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
## Associate the Mgmt Subnets with the Public Route Table
resource "aws_route_table_association" "mgmt_subnet_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.edge_mgmt_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

### Private Default Route
### Routing Table for the Private Subnets
#resource "aws_route_table" "private_route_table" {
#  count  = length(var.aws_availability_zones)
#  vpc_id = aws_vpc.edge_vpc.id
#  tags = {
#    name = "${var.env_name}-private-rt"
#  }
#}
### Associate the Private Subnets to the Private Route Tables
#resource "aws_route_table_association" "private_subnet_association" {
#  count          = length(var.aws_availability_zones)
#  subnet_id      = aws_subnet.edge_private_subnet[count.index].id
#  route_table_id = aws_route_table.private_route_table[count.index].id
#}
#
### Data Source for the GWLB Endpoint created with the Egress Gateway
#data "ciscomcd_gateway" "gw" {
#  name = ciscomcd_gateway.egress_gw.name
#}
#
### Private Subnet Route
### Private Subnets Default route to the Gateway Load Balancer Endpoint
#resource "aws_route" "gwlb_route" {
#  count                  = length(var.aws_availability_zones)
#  route_table_id         = aws_route_table.private_route_table[count.index].id
#  destination_cidr_block = "0.0.0.0/0"
#  vpc_endpoint_id        = data.ciscomcd_gateway.gw.gateway_gwlb_endpoints[count.index].endpoint_id
#}
#
#data "ciscomcd_gateway" "ingress_gw" {
#  name = ciscomcd_gateway.ingress-gw.name
#}
#
#### Private Subnets Default route to the Gateway Load Balancer Endpoint
#resource "aws_route" "ingress_gw_route" {
#  count                  = length(var.aws_availability_zones)
#  route_table_id         = aws_route_table.private_route_table[count.index].id
#  destination_cidr_block = aws_subnet.edge_public_subnet[count.index].cidr_block
#  gateway_id             = ciscomcd_gateway.ingress-gw[count.index].id
#}