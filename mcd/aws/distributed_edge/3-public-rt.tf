# Public Routing

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
