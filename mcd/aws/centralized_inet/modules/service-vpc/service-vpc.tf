terraform {
  required_providers {
    ciscomcd = {
      source = "CiscoDevNet/ciscomcd"
      version = "0.2.4"
    }
  }
}

# Data Sources
data "ciscomcd_cloud_account" "account_name" {
  name = var.ciscomcd_account
}

# Service VPC

resource "ciscomcd_service_vpc" "service-vpc" {

	name = "${var.env_name}-${var.ingress_egress}-service-vpc"
	csp_account_name = data.ciscomcd_cloud_account.account_name.name
	region = var.aws_region
	cidr = var.vpc_cidr
	availability_zones = var.aws_availability_zones
	transit_gateway_id = var.transit_gateway_id
	use_nat_gateway = var.use_nat_gateway
}

# Policy Rule Set

resource "ciscomcd_policy_rule_set" "policy" {
  name = "${var.env_name}-${var.ingress_egress}-policy-ruleset"
}

# Gateway
resource "ciscomcd_gateway" "gateway" {
	name = "${var.env_name}-${var.ingress_egress}-gateway"
	csp_account_name = data.ciscomcd_cloud_account.account_name.name
	instance_type = var.gateway_instance_type
	mode = "HUB"
	policy_rule_set_id = ciscomcd_policy_rule_set.policy.id
	min_instances = var.aws_min_instances
	max_instances = var.aws_max_instances
	health_check_port = 65534
	region = var.aws_region
	vpc_id = ciscomcd_service_vpc.service-vpc.id
	aws_iam_role_firewall = var.aws_iam_role
	gateway_image = var.gateway_image
	ssh_key_pair = var.ssh_key_pair
	security_type = upper(var.ingress_egress)
	aws_gateway_lb = var.aws_gateway_lb
	settings {
		name = "controller.gateway.assign_public_ip"
		value = "true"
	}
	settings {
		name = "gateway.aws.ebs.encryption.key.default"
		value = ""
	}
	settings {
		name = "gateway.snat_mode"
		value = "0"
	}
}
