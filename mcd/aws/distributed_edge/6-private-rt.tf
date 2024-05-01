## Private Route Table

## Routing Table for the Private Subnets
resource "aws_route_table" "private_route_table" {
  count  = length(var.aws_availability_zones)
  vpc_id = aws_vpc.edge_vpc.id
  tags = {
    name = "${var.env_name}-private-rt-${count.index + 1}"
  }
}

## Associate the Private Subnets to the Private Route Tables
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.edge_private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

## Private Subnets Default route to the Gateway Load Balancer Endpoint
resource "aws_route" "gwlb_route" {
  count                  = length(var.aws_availability_zones)
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = ciscomcd_gateway.egress_gw.gateway_gwlb_endpoints[count.index].endpoint_id
}