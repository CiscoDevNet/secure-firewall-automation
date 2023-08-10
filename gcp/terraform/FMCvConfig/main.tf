
terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      # version = "0.1.1"
    }
  }
}

provider "fmc" {
  fmc_username = var.fmc_username
  fmc_password = var.fmc_password
  fmc_host = var.fmc_host
  fmc_insecure_skip_verify = var.fmc_insecure_skip_verify
}

################################################################################################
# Data blocks
################################################################################################
data "fmc_port_objects" "http" {
    name = "HTTP"
}
data "fmc_network_objects" "any-ipv4"{
    name = "any-ipv4"
}
data "fmc_device_physical_interfaces" "zero_physical_interface" {
    device_id = fmc_devices.device.id
    name = "GigabitEthernet0/0"
}
data "fmc_device_physical_interfaces" "one_physical_interface" {
    device_id = fmc_devices.device.id
    name = "GigabitEthernet0/1"
}

################################################################################################
# Resource blocks
################################################################################################
resource "fmc_smart_license" "license" {
  registration_type = "EVALUATION"
}
resource "fmc_security_zone" "inside" {
  name            = "inside"
  interface_mode  = "ROUTED"
}
resource "fmc_security_zone" "outside" {
  name            = "outside"
  interface_mode  = "ROUTED"
}

resource "fmc_host_objects" "default_gateway" {
  name        = "default-gateway"
  value       = "10.10.0.1"
}
resource "fmc_host_objects" "inside-gw" {
  name        = "inside-gateway"
  value       = "10.10.1.1"
}
resource "fmc_host_objects" "app_lb" {
  name        = "app_lb"
  value       = "10.10.6.2"
}
resource "fmc_network_objects" "app" {
  name        = "app"
  value       = "10.10.6.0/24"
}
resource "fmc_access_policies" "access_policy" {
  depends_on = [ fmc_smart_license.license ]
  name = "IAC-ACP"
  default_action = "BLOCK"
  default_action_send_events_to_fmc = "true"
  default_action_log_end = "true"
}

resource "fmc_access_rules" "access_rule_1" {
    acp = fmc_access_policies.access_policy.id
    section = "mandatory"
    name = "To Web Server"
    action = "allow"
    enabled = true
    send_events_to_fmc = true
    log_end = true
    destination_networks {
        destination_network {
            id = fmc_host_objects.app_lb.id
            type =  fmc_host_objects.app_lb.type
        }
    }
    source_zones {
        source_zone {
            id = fmc_security_zone.outside.id
            type =  "SecurityZone"
        }
    }
    destination_zones {
        destination_zone {
            id = fmc_security_zone.inside.id
            type =  "SecurityZone"
        }
    }
    new_comments = [ "Applied via terraform" ]
}

resource "fmc_ftd_nat_policies" "nat_policy" {
    name = "NAT_Policy"
    description = "For GCP"
}

resource "fmc_ftd_manualnat_rules" "new_rule" {
    nat_policy = fmc_ftd_nat_policies.nat_policy.id
    nat_type = "static"
    original_source{
        id = data.fmc_network_objects.any-ipv4.id
        type = data.fmc_network_objects.any-ipv4.type
    }
    original_destination_port {
        id = data.fmc_port_objects.http.id
        type = data.fmc_port_objects.http.type
    }
    translated_destination_port {
        id = data.fmc_port_objects.http.id
        type = data.fmc_port_objects.http.type
    }
    translated_destination {
        id = fmc_host_objects.app_lb.id
        type = fmc_host_objects.app_lb.type
    }
    source_interface {
        id = fmc_security_zone.outside.id
        type = "SecurityZone"
    }
    destination_interface {
        id = fmc_security_zone.inside.id
        type = "SecurityZone"
    }
    
    interface_in_original_destination = true
    interface_in_translated_source = true
}

resource "fmc_devices" "device"{
  depends_on = [fmc_ftd_nat_policies.nat_policy, fmc_security_zone.inside, fmc_security_zone.outside]
  name = "FTD1"
  hostname = "10.10.2.10"
  regkey = "cisco"
  license_caps = [ "MALWARE"]
  access_policy {
      id = fmc_access_policies.access_policy.id
      type = fmc_access_policies.access_policy.type
  }
}
##############################
resource "fmc_device_physical_interfaces" "physical_interfaces00" {
    enabled = true
    device_id = fmc_devices.device.id
    physical_interface_id= data.fmc_device_physical_interfaces.zero_physical_interface.id
    name =   data.fmc_device_physical_interfaces.zero_physical_interface.name
    security_zone_id= fmc_security_zone.outside.id
    if_name = "outside"
    mtu =  1500
    mode = "NONE"
    ipv4_dhcp_enabled = true
    ipv4_dhcp_route_metric = 1
}
resource "fmc_device_physical_interfaces" "physical_interfaces01" {
    device_id = fmc_devices.device.id
    physical_interface_id= data.fmc_device_physical_interfaces.one_physical_interface.id
    name =   data.fmc_device_physical_interfaces.one_physical_interface.name
    security_zone_id= fmc_security_zone.inside.id
    if_name = "inside"
    mtu =  1500
    mode = "NONE"
    ipv4_dhcp_enabled = true
    ipv4_dhcp_route_metric = 1
}

resource "fmc_staticIPv4_route" "route" {
  depends_on = [fmc_devices.device, fmc_device_physical_interfaces.physical_interfaces00,fmc_device_physical_interfaces.physical_interfaces01]
  metric_value = 1
  device_id  = fmc_devices.device.id
  interface_name = "inside"
  selected_networks {
      id = fmc_network_objects.app.id
      type = fmc_network_objects.app.type
      name = fmc_network_objects.app.name
  }
  gateway {
    object {
      id   = fmc_host_objects.default_gateway.id
      type = fmc_host_objects.default_gateway.type
      name = fmc_host_objects.default_gateway.name
    }
  }
}
resource "fmc_staticIPv4_route" "def_route" {
  depends_on = [fmc_staticIPv4_route.route]
  metric_value = 2
  device_id  = fmc_devices.device.id
  interface_name = "outside"
  selected_networks {
      id = data.fmc_network_objects.any-ipv4.id
      type = data.fmc_network_objects.any-ipv4.type
      name = data.fmc_network_objects.any-ipv4.name
  }
  gateway {
    object {
      id   = fmc_host_objects.default_gateway.id
      type = fmc_host_objects.default_gateway.type
      name = fmc_host_objects.default_gateway.name
    }
  }
}
resource "fmc_policy_devices_assignments" "fmc_policy_devices_assignments" {
  depends_on = [fmc_staticIPv4_route.def_route]
  policy {
      id = fmc_ftd_nat_policies.nat_policy.id
      type = fmc_ftd_nat_policies.nat_policy.type
  }
  target_devices {
      id = fmc_devices.device.id
      type = fmc_devices.device.type
  }
}

resource "fmc_ftd_deploy" "ftd" {
    depends_on = [fmc_policy_devices_assignments.fmc_policy_devices_assignments]
    device = fmc_devices.device.id
    ignore_warning = true
    force_deploy = false
}
