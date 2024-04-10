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

#data "aws_lb" "eks-alb" {
#  name = "eks-alb-ingress"
#}

###################
## Address Objects
###################

# Yelb Address - Mapped to Yelb NLB DNS Name

resource "ciscomcd_address_object" "yelb-app" {
	name = "yelb-app"
	description = "Mapped to Yelb NLB DNS Name"
	type = "STATIC"
	value = [module.yelb-vpc.app_lb_dns_name]
	backend_address = true
}


####################
# Service Objects
####################

# Yelb App Service Object

resource "ciscomcd_service_object" "yelb-app" {
	name = "yelb-app"
	description = "Yelb app Service Port"
	service_type = "ReverseProxy"
	protocol = "TCP"
	source_nat = false
	backend_address_group = ciscomcd_address_object.yelb-app.id
	transport_mode = "HTTP"
		port {
			destination_ports = "8080"
			backend_ports = "8080"
		}
}


###############################
# Ingress Rules
###############################

resource "ciscomcd_policy_rules" "ingress_rules" {
	rule_set_id = module.yelb-vpc.policy_rule_set_id
	rule {
		name = "yelb-app"
		description = "Inbound Access to Yelb App"
		action = "Allow Log"
		state = "ENABLED"
		service = ciscomcd_service_object.yelb-app.id
		source = data.ciscomcd_address_object.any_ag.id
		packet_capture_enabled = false
		send_deny_reset = false
		type = "ReverseProxy"
	}
}


########################
# Egress Policy Rules
########################

# Permit Any Outbound to Internet

resource "ciscomcd_policy_rules" "egress-policy-rules" {
  depends_on = [module.egress-service-vpc]
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

