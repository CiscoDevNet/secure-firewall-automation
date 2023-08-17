terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.62.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "myVirtualNetwork" {
  name                = "myVirtualNetwork"
  resource_group_name = "yourResourceGroupName"
  location            = "yourResourceGroupLocation"
  address_space       = ["10.1.0.0/16"]
}
