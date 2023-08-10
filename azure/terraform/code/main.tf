module "network" {
  source         = "../module/Network/"
  location       = var.location
  create_rg      = var.create_rg
  rg_name        = var.rg_name
  vn_name        = var.vn_name
  prefix         = var.prefix
  vn_cidr        = var.vn_cidr
  source_address = var.source_address
  instances      = var.instances 
  subnet_size    = var.subnet_size
  create_fmc     = var.create_fmc
  fmc_ip         = var.fmc_ip
  ftd_mgmt_ip    = var.ftd_mgmt_ip 
  
}

module "firewall" {
  source                  = "../module/FirewallServer/"
  location                = var.location
  prefix                  = var.prefix
  instances               = var.instances 
  vm_size                 = var.vm_size
  ftd_image_version       = var.ftd_image_version
  fmc_image_version       = var.fmc_image_version
  ftd_password            = var.ftd_password
  fmc_password            = var.fmc_password 
  instancename            = var.instancename
  fmc_ip                  = var.fmc_ip
  create_fmc              = var.create_fmc 
  reg_key                 = var.reg_key
  fmc_nat_id              = var.fmc_nat_id
  keypair                 = module.network.keypair
  ftd_mgmt_interface      = module.network.mgmt_interface
  ftd_outside_interface   = module.network.outside_interface
  ftd_inside_interface    = module.network.inside_interface
  ftd_diag_interface      = module.network.diag_interface
  fmc_mgmt_interface      = module.network.fmc_mgmt_interface
  rg_name                 = module.network.RGname 
  
}