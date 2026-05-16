variable "deploy_bastion" {
  default = false
}


data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.resource_group_name
}

# Bastion Public IP
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

# Required Azure Bastion Subnet #using already existing subnet in the hub virtual network
data "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = var.resource_group_name
}

# creating new bastion subnet using the azurerm_subnet resource. was causing issues with the bastion host deployment, so switched to using data source to reference the existing subnet in the hub virtual network. This allows the bastion host to be deployed successfully without conflicts. The bastion host will use the existing subnet and public IP for its configuration.
/*
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub.name

  address_prefixes = ["10.0.254.0/27"]
}
*/


# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "bas-hub"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Basic"

  ip_configuration {
    name                 = "bastion-ip-config"
    #subnet_id            = azurerm_subnet.bastion.id
    subnet_id = data.azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = var.tags
}