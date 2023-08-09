terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
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
data "fmc_port_objects" "ssh" {
    name = "SSH"
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

resource "fmc_host_objects" "server" {
  name        = "server"
  value       = "169.254.169.254"
}
resource "fmc_host_objects" "inside-gw" {
  name        = "inside-gateway"
  value       = "10.0.5.1" 
}


# Network Objects
resource "fmc_network_objects" "inside" {
  name        = "inside_subnet"
  value       = "10.0.5.0/24"
  description = "Internal Network"
}

resource "fmc_network_objects" "outside" {
  name        = "outside_subnet"
  value       = "10.0.4.0/24"
  description = "Outside Network"
}

# Port Objects
resource "fmc_port_objects" "http_8080" {
    name = "HTTP_8080"
    port = "8080"
    protocol = "TCP"
}

resource "fmc_access_policies" "access_policy" {
  name = "Terraform Access Policy"
  default_action = "BLOCK"
  default_action_send_events_to_fmc = "true"
  default_action_log_end = "true"
}

resource "fmc_access_rules" "access_rule_1" {
    acp = fmc_access_policies.access_policy.id
    section = "mandatory"
    name = "Rule-1"
    action = "allow"
    enabled = true
    send_events_to_fmc = true
    log_end = true
    destination_networks {
        destination_network {
            id = fmc_host_objects.server.id
            type =  fmc_host_objects.server.type
        }
    }
    destination_ports {
        destination_port {
            id = data.fmc_port_objects.http.id
            type =  data.fmc_port_objects.http.type
        }
    }
    new_comments = [ "Testing via terraform" ]
}

resource "fmc_ftd_nat_policies" "nat_policy" {
    name = "NAT_Policy"
    description = "Nat policy by terraform"
}

resource "fmc_ftd_manualnat_rules" "new_rule" {
    nat_policy = fmc_ftd_nat_policies.nat_policy.id
    nat_type = "static"
    original_source{
        id = data.fmc_network_objects.any-ipv4.id
        type = data.fmc_network_objects.any-ipv4.type
    }
    source_interface {
        id = fmc_security_zone.outside.id
        type = "SecurityZone"
    }
    destination_interface {
        id = fmc_security_zone.inside.id
        type = "SecurityZone"
    }
    original_destination_port {
        id = data.fmc_port_objects.ssh.id
        type = data.fmc_port_objects.ssh.type
    }
    translated_destination_port {
        id = data.fmc_port_objects.http.id
        type = data.fmc_port_objects.http.type
    }
    translated_destination {
        id = fmc_host_objects.server.id
        type = fmc_host_objects.server.type
    }
    interface_in_original_destination = true
    interface_in_translated_source = true
}

resource "fmc_devices" "device"{
  depends_on = [fmc_ftd_nat_policies.nat_policy, fmc_security_zone.inside, fmc_security_zone.outside]
  name = "FTD1"
  hostname = var.ftd_ip
  regkey = "cisco"
  license_caps = [ "MALWARE"]
  nat_id = "cisco"
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
    description = "Applied by terraform"
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
    description = "Applied by terraform"
    mtu =  1500
    mode = "NONE"
    ipv4_dhcp_enabled = true
    ipv4_dhcp_route_metric = 1
}

resource "fmc_staticIPv4_route" "route" {
  depends_on = [fmc_devices.device, fmc_device_physical_interfaces.physical_interfaces00,fmc_device_physical_interfaces.physical_interfaces01]
  metric_value = 25
  device_id  = fmc_devices.device.id
  interface_name = "inside"
  selected_networks {
      id = fmc_host_objects.server.id
      type = fmc_host_objects.server.type
      name = fmc_host_objects.server.name
  }
  gateway {
    object {
      id   = fmc_host_objects.inside-gw.id
      type = fmc_host_objects.inside-gw.type
      name = fmc_host_objects.inside-gw.name
    }
  }
}

resource "fmc_policy_devices_assignments" "policy_assignment" {
  depends_on = [fmc_staticIPv4_route.route]
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
    depends_on = [fmc_policy_devices_assignments.policy_assignment]
    device = fmc_devices.device.id
    ignore_warning = true
    force_deploy = false
}


