## Ingress Policy Rule Set

# App Address Object - Mapped to NLB DNS Name
resource "ciscomcd_address_object" "app" {
	name = "${var.env_name}-app"
	description = "Mapped to NLB DNS Name"
	type = "STATIC"
	value = [aws_lb.app-lb.dns_name]
	backend_address = true
}

# App Service Object
resource "ciscomcd_service_object" "app" {
  name                  = "${var.env_name}-app"
  description           = "App Service Port"
  service_type          = "ReverseProxy"
  protocol              = "TCP"
  source_nat            = false
  backend_address_group = ciscomcd_address_object.app.id
  transport_mode        = "HTTP"
  port {
    destination_ports = "8080"
    backend_ports     = "8080"
  }
}

# Ingress Policy Rules
resource "ciscomcd_policy_rules" "ingress_rules" {
	rule_set_id = ciscomcd_policy_rule_set.ingress_policy.id
	rule {
		name = "yelb-app"
		description = "Inbound Access to Yelb App"
		action = "Allow Log"
		state = "ENABLED"
		service = ciscomcd_service_object.app.id
		source = data.ciscomcd_address_object.any_ag.id
		packet_capture_enabled = false
		send_deny_reset = false
		type = "ReverseProxy"
	}
}