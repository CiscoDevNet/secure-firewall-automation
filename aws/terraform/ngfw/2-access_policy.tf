#############################################
# FTD1 Configuration
#############################################

#############################################
# Data Sources
#############################################
data "fmc_devices" "ftd1" {
    depends_on = [fmc_devices.ftd1]
    name = "FTD1"
}

data "fmc_access_policies" "acp" {
    depends_on = [fmc_access_policies.access_policy]
    name = "FTD1-Access-Policy"
}

data "fmc_device_physical_interfaces" "int_0" {
    name      = "TenGigabitEthernet0/0"
    device_id = data.fmc_devices.ftd1.id
}

data "fmc_device_physical_interfaces" "int_1" {
    name      = "TenGigabitEthernet0/1"
    device_id = data.fmc_devices.ftd1.id
}

data "fmc_port_objects" "http" {
    name = "HTTP"
}
data "fmc_port_objects" "https" {
    name = "HTTPS"
}
data "fmc_ips_policies" "ips_policy" {
    name = "Connectivity Over Security"
}

##########################################
# Security Zones
##########################################

resource "fmc_security_zone" "external" {
  name           = "external"
  interface_mode = "ROUTED"
}

resource "fmc_security_zone" "internal" {
  name           = "internal"
  interface_mode = "ROUTED"
}

#####################################################
# Interfaces
#####################################################

resource "fmc_device_physical_interfaces" "outside" {
    depends_on = [fmc_security_zone.external]
    name = data.fmc_device_physical_interfaces.int_0.name
    device_id = data.fmc_devices.ftd1.id
    physical_interface_id = data.fmc_device_physical_interfaces.int_0.id
    security_zone_id = fmc_security_zone.external.id
    if_name = "Outside"
    description = "External interface to internet gateway"
    mtu = 1700
    mode = "NONE"
    ipv4_dhcp_enabled = true
    ipv4_dhcp_route_metric = 1
    enabled = true
}

resource "fmc_device_physical_interfaces" "inside" {
    depends_on = [fmc_security_zone.internal]
    name = data.fmc_device_physical_interfaces.int_1.name
    device_id = data.fmc_devices.ftd1.id
    physical_interface_id = data.fmc_device_physical_interfaces.int_1.id
    security_zone_id = fmc_security_zone.internal.id
    if_name = "Inside"
    description = "Internal interface to application"
    mtu = 1700
    mode = "NONE"
    ipv4_dhcp_enabled = true
    ipv4_dhcp_route_metric = 1
    enabled = true
}

#########################################
# Objects
#########################################

# Network Objects
resource "fmc_network_objects" "inside" {
  name        = "inside_subnet"
  value       = var.inside_subnet
  description = "Internal Network"
}

resource "fmc_network_objects" "outside" {
  name        = "outside_subnet"
  value       = var.outside_subnet
  description = "Outside Network"
}

# Host Objects
resource "fmc_host_objects" "web_server" {
    name        = "Web_Server_Int"
    value       = "172.16.3.50"
    description = "internal address"
}

resource "fmc_host_objects" "web_server_ext" {
    name        = "Web_Server_Ext"
    value       = "172.16.2.50"
    description = "external nat address"
}


# Port Objects
resource "fmc_port_objects" "http_8080" {
    name = "HTTP_8080"
    port = "8080"
    protocol = "TCP"
}

# URL Objects
resource "fmc_url_objects" "cisco-home" {
    name        = "cisco-home"
    url       = "https://www.cisco.com/"
    description = "Cisco home page"
}

# FQDN Object
resource "fmc_fqdn_objects" "cisco" {
  name        = "Cisco"
  value       = "cisco.com"
  description = "Cisco domain"
  dns_resolution = "IPV4_ONLY"
}

#########################################################
# Access Control Policy Rules
#########################################################

resource "fmc_access_rules" "access_rule_1" {
    depends_on = [data.fmc_access_policies.acp]
    acp                = data.fmc_access_policies.acp.id
    section            = "mandatory"
    name               = "Permit Outbound"
    action             = "allow"
    enabled            = true
    send_events_to_fmc = true
    log_files          = false
    log_begin          = true
    log_end            = true
    source_zones {
        source_zone {
            id   = fmc_security_zone.internal.id
            type = "SecurityZone"
        }
    }
    destination_zones {
        destination_zone {
            id   = fmc_security_zone.external.id
            type = "SecurityZone"
        }
    }
    source_networks {
        source_network {
            id   = fmc_network_objects.inside.id
            type = "Network"
        }
    }
    new_comments       = ["outbound traffic"]
}

resource "fmc_access_rules" "access_rule_2" {
    depends_on = [data.fmc_access_policies.acp]
    acp                = data.fmc_access_policies.acp.id
    section            = "mandatory"
    name               = "Access to Web Server"
    action             = "allow"
    enabled            = true
    send_events_to_fmc = true
    log_files          = false
    log_begin          = true
    log_end            = true
    source_zones {
        source_zone {
            id   = fmc_security_zone.external.id
            type = "SecurityZone"
        }
    }
    destination_zones {
        destination_zone {
            id   = fmc_security_zone.internal.id
            type = "SecurityZone"
        }
    }
    destination_networks {
        destination_network {
            id = fmc_host_objects.web_server.id
            type =  "Host"
        }
    }
    destination_ports {
        destination_port {
            id = fmc_port_objects.http_8080.id
            type = "TCPPortObject"
        }
    }
    new_comments       = ["Web Server"]
}

resource "fmc_access_rules" "access_rule_3" {
    depends_on = [data.fmc_access_policies.acp]
    acp                = data.fmc_access_policies.acp.id
    section            = "mandatory"
    insert_before      = 1
    name               = "Access to Cisco"
    action             = "allow"
    enabled            = true
    send_events_to_fmc = true
    log_files          = false
    log_end            = true
    source_zones {
        source_zone {
            id   = fmc_security_zone.internal.id
            type = "SecurityZone"
        }
    }
    destination_zones {
        destination_zone {
            id   = fmc_security_zone.external.id
            type = "SecurityZone"
        }
    }
    source_networks {
        source_network {
            id   = fmc_network_objects.inside.id
            type = "Network"
        }
    }
    destination_networks {

        destination_network {
            id   = fmc_fqdn_objects.cisco.id
            type = "FQDN"
        }
    }
    destination_ports {
        destination_port {
            id   = data.fmc_port_objects.http.id
            type = "TCPPortObject"
        }
        destination_port {
            id   = data.fmc_port_objects.https.id
            type = "TCPPortObject"
        }
    }
    urls {
        url {
            id   = fmc_url_objects.cisco-home.id
            type = "Url"
        }
    }
    ips_policy   = data.fmc_ips_policies.ips_policy.id
    new_comments = ["New", "ips"]
}


##########################################################
# NAT Policy
##########################################################

resource "fmc_ftd_nat_policies" "ftd_nat_policy" {
    depends_on = [data.fmc_devices.ftd1]
    name = "FTD-01 NAT Policy"
    description = "FTD-01 NAT policy!"
}

resource "fmc_ftd_autonat_rules" "outbound_nat" {
    depends_on = [fmc_ftd_nat_policies.ftd_nat_policy]
    nat_policy = fmc_ftd_nat_policies.ftd_nat_policy.id
    description = "Outbound PAT"
    nat_type = "dynamic"
    source_interface {
        id = fmc_security_zone.internal.id
        type = "SecurityZone"
    }
    destination_interface {
        id = fmc_security_zone.external.id
        type = "SecurityZone"
    }
    original_network {
        id = fmc_network_objects.inside.id
        type = "Network"
    }
    pat_options {
        interface_pat = true
    }
}

resource "fmc_ftd_autonat_rules" "web_server" {
    depends_on = [fmc_ftd_nat_policies.ftd_nat_policy]
    nat_policy   = fmc_ftd_nat_policies.ftd_nat_policy.id
    description  = "Web Server Nat"
    nat_type     = "static"
    source_interface {
        id   = fmc_security_zone.internal.id
        type = "SecurityZone"
    }
    destination_interface {
        id   = fmc_security_zone.external.id
        type = "SecurityZone"
    }
    original_network {
        id   = fmc_host_objects.web_server.id
        type = "Host"
    }
    translated_network {
        id   = fmc_host_objects.web_server_ext.id
        type = "Host"
    }
    translated_network_is_destination_interface = false
}

resource "fmc_policy_devices_assignments" "nat_policy_assignment" {
    depends_on = [fmc_ftd_nat_policies.ftd_nat_policy]
    policy {
        id = fmc_ftd_nat_policies.ftd_nat_policy.id
        type = "FTDNatPolicy"
    }
    target_devices {
        id = data.fmc_devices.ftd1.id
        type = "Device"
    }
}

#####################################################
# Deploy Policy to FTD Device
#####################################################

resource "fmc_ftd_deploy" "ftd" {
    depends_on = [
        fmc_access_rules.access_rule_1,
        fmc_access_rules.access_rule_2,
        fmc_access_rules.access_rule_3
    ]
    device = data.fmc_devices.ftd1.id
    ignore_warning = false
    force_deploy = false
}