output "spoke_subnets" {
  value = aws_subnet.spoke_subnet
}
output "spoke_vpc_id" {
  value = aws_vpc.spoke_vpc.id
}