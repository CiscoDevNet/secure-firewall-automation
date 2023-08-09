resource "azurerm_virtual_machine" "ftdv-instance" {
  name                = "${var.prefix}-vm%{if var.instances > 1}-${count.index}%{endif}"
  count               = var.instances
  location            = var.location
  resource_group_name = var.rg_name

  primary_network_interface_id = element(var.ftd_mgmt_interface,count.index)
  network_interface_ids = [
    element(var.ftd_mgmt_interface,count.index),
    element(var.ftd_diag_interface,count.index),
    element(var.ftd_outside_interface,count.index),
    element(var.ftd_inside_interface,count.index)
  ]
  vm_size = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  plan {
    name      = "ftdv-azure-byol"
    publisher = "cisco"
    product   = "cisco-ftdv"
  }

  storage_image_reference {
    publisher = "cisco"
    offer     = "cisco-ftdv"
    sku       = "ftdv-azure-byol"
    version   = var.ftd_image_version
  }
  storage_os_disk {
    name              = "${var.prefix}-myosdisk%{if var.instances > 1}-${count.index}%{endif}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.instancename}%{if var.instances > 1}${count.index}%{endif}"
    admin_username = var.username
    admin_password = var.ftd_password
    custom_data = templatefile(
      "${path.module}/ftd_startup_file.txt", {
        ftd_password = var.ftd_password,
        fmc_ip = var.fmc_ip,
        reg_key = var.reg_key,
        fmc_nat_id = var.fmc_nat_id
      }
    )
  }
  os_profile_linux_config {
    disable_password_authentication = false    
    ssh_keys {
      key_data = var.keypair
      path = "/home/cisco/.ssh/authorized_keys"
    }
  }
  zones = var.instances == 1 ? [] : [local.az_distribution[count.index]]
}

resource "azurerm_linux_virtual_machine" "fmcv" {
  name                  = "FMC-01"
  count                 = var.create_fmc == true ? 1:0
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [element(var.fmc_mgmt_interface,count.index)]//[var.fmc_mgmt_interface]
  size                  = "Standard_D4_v2"
  disable_password_authentication = false

  os_disk {
    name                 = "FMC-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  plan {
    name      = "fmcv-azure-byol"
    product   = "cisco-fmcv"
    publisher = "cisco"
  }

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-fmcv"
    sku       = "fmcv-azure-byol"
    version   = var.fmc_image_version
  }

  computer_name  = "FMC"
  admin_username = var.username
  admin_password = var.fmc_password
  custom_data = base64encode(templatefile(
    "${path.module}/fmc_startup_file.txt", {
      fmc_password = var.fmc_password,
      fmc_hostname = "FMC01"
    }
  )) 
}