# Data Sources
data "ciscomcd_address_object" "any_ag" {
  name = "any"
}

data "ciscomcd_address_object" "any_private_rfc1918_ag" {
  name = "any-private-rfc1918"
}

data "ciscomcd_address_object" "internet_ag" {
  name = "internet"
}

data "ciscomcd_service_object" "forwarding_tcp_any" {
  name = "valtix-sample-egress-forwarding-snat"
}


########################
# Egress Policy Rules
########################

# Permit Any Outbound to Internet

resource "ciscomcd_policy_rules" "egress-policy-rules" {
  depends_on = [ciscomcd_gateway.egress_gw]
    rule_set_id = ciscomcd_policy_rule_set.egress_policy.id
    rule {
        name        = "private-to-internet"
        action      = "Allow Log"
        state       = "ENABLED"
        service     = data.ciscomcd_service_object.forwarding_tcp_any.id
        source      = data.ciscomcd_address_object.any_private_rfc1918_ag.id
        destination = data.ciscomcd_address_object.internet_ag.id
        type        = "Forwarding"
    }
    rule {
        name        = "any-to-any"
        action      = "Deny Log"
        state       = "ENABLED"
        service     = data.ciscomcd_service_object.forwarding_tcp_any.id
        source      = data.ciscomcd_address_object.any_ag.id
        destination = data.ciscomcd_address_object.any_ag.id
        type        = "Forwarding"
    }
}

