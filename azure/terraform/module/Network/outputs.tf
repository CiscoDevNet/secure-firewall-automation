##################################################################################################################################
#Output
##################################################################################################################################

output "FTDv_Instance_Public_IPs" {
  value = azurerm_public_ip.ftdv-mgmt-interface[*].ip_address
}

output "FMC_Instance_Public_IPs" {
  value = azurerm_public_ip.fmc-mgmt-interface[*].ip_address
}

output "outside_subnet" {
  value = azurerm_subnet.subnets["outside"].id
}
output "inside_subnet" {
  value = azurerm_subnet.subnets["inside"].id
}

output "mgmt_interface" {
  value = azurerm_network_interface.ftdv-mgmt.*.id
}
output "inside_interface" {
  value = azurerm_network_interface.ftdv-inside.*.id
}
output "outside_interface" {
  value = azurerm_network_interface.ftdv-outside.*.id
}
output "diag_interface" {
  value = azurerm_network_interface.ftdv-diagnostic.*.id
}
output "fmc_mgmt_interface" {
  value = azurerm_network_interface.fmc-mgmt[*].id
}


output "RGname" {
  value = local.rg_name
}

output "inside_addr_prefix"{
  value = azurerm_subnet.subnets["inside"].address_prefixes[0]
}

output "virtual_network" {
  value = azurerm_virtual_network.ftdv[0].id
}
output "virtual_network_name" {
  value = azurerm_virtual_network.ftdv[0].name
}

output "inside_private_ips" {
  value = azurerm_network_interface.ftdv-inside.*.private_ip_address
}
output "outside_private_ips" {
  value = azurerm_network_interface.ftdv-outside.*.private_ip_address
}

output "keypair" {
  value = tls_private_key.key_pair.public_key_openssh
}