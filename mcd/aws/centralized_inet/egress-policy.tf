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

# Egress Policy Rules

resource "ciscomcd_policy_rules" "egress-policy-rules" {
    rule_set_id = module.egress-service-vpc.policy_rule_set_id
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