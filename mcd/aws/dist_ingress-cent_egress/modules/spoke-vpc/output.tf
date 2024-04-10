#output "spoke_subnets" {
#  value = aws_subnet.spoke_subnet
#}
output "spoke_vpc_id" {
  value = aws_vpc.spoke_vpc.id
}
output "policy_rule_set_id" {
  value = ciscomcd_policy_rule_set.ingress_policy.id
}
output "app_lb_dns_name" {
  value = aws_lb.app-lb.dns_name
}