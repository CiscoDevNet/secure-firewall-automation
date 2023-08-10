locals {
  rg_name = var.create_rg ? azurerm_resource_group.ftdv[0].name : var.rg_name
  vn_name = var.create_vn ? azurerm_virtual_network.ftdv[0].name : var.vn_name
  subnet_list = {
    "management" = 0
    "diagnostic" = 1
    "outside"    = 2
    "inside"     = 3
  }
  az_distribution = chunklist(sort(flatten(chunklist(setproduct(range(var.instances), var.azs), var.instances)[0])), var.instances)[1]
  vn_cidr         = var.vn_cidr 
  subnet_newbits  = var.subnet_size - tonumber(split("/", local.vn_cidr)[1])
}

