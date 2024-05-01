# Cisco Multicloud Defense Egress Gateway

# Policy Rule Set

resource "ciscomcd_policy_rule_set" "egress_policy" {
  name = "${var.env_name}-egress-policy-ruleset"
}

## Deploys Egress Gateways and AWS Gateway Load Balancers in Public Subnets.
## Used to inspect outbound traffic to the internet
resource "ciscomcd_gateway" "egress_gw" {
  name                    = "${var.env_name}-egress-gw"
  description             = "${var.env_name}-egress-gw"
  csp_account_name        = var.ciscomcd_account
  instance_type           = var.gateway_instance_type
  gateway_image           = var.gateway_image
  gateway_state           = "ACTIVE"
  mode                    = "EDGE"
  security_type           = "EGRESS"
  policy_rule_set_id      = ciscomcd_policy_rule_set.egress_policy.id
  ssh_key_pair            = aws_key_pair.public_key.key_name
  aws_iam_role_firewall   = var.aws_iam_role
  region                  = var.aws_region
  vpc_id                  = aws_vpc.edge_vpc.id
  mgmt_security_group     = aws_security_group.mgmt-sg.id
  datapath_security_group = aws_security_group.data-sg.id
  aws_gateway_lb          = true
  instance_details {
    availability_zone = var.aws_availability_zones[0]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[0].id
    datapath_subnet   = aws_subnet.edge_public_subnet[0].id
  }
  instance_details {
    availability_zone = var.aws_availability_zones[1]
    mgmt_subnet       = aws_subnet.edge_mgmt_subnet[1].id
    datapath_subnet   = aws_subnet.edge_public_subnet[1].id
  }
}