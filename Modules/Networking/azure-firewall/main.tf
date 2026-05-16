data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.resource_group_name
}

# For creating New Azure Firewall Subnet. but already exists, so using data source to fetch it.
/*
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub.name

  address_prefixes = ["10.0.253.0/26"]
}
*/
# Fetching existing Azure Firewall Subnet using data source since it already exists in the hub virtual network. This allows us to reference the existing subnet for the firewall configuration without trying to create a new one, which would cause a conflict. The firewall will use this existing subnet for its deployment and configuration.
data "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = var.resource_group_name
}


# Firewall Public IP. Data plane.This IP is used for the firewall's outbound connectivity and for receiving inbound traffic based on the firewall rules. It allows the firewall to communicate with external resources and services while enforcing the defined security policies.
resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-azure-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

# Firewall Management Public IP required for Azure Firewall Manager management plane connectivity. This IP is used for communication between the firewall and Azure Firewall Manager for policy management and monitoring.
resource "azurerm_public_ip" "firewall_mgmt_pip" {
  name                = "pip-azure-firewall-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "fw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = "Basic"

  tags = var.tags
}

# Azure Firewall
resource "azurerm_firewall" "firewall" {
  name                = "azfw-hub"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "AZFW_VNet"
  sku_tier = "Basic"

  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "fw-ip-config"
    #subnet_id            = azurerm_subnet.firewall.id
    subnet_id = data.azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  tags = var.tags
# Azure Firewall Management IP Configuration
management_ip_configuration {
  name                 = "fw-management-config"
  subnet_id            = data.azurerm_subnet.firewall_management.id
  public_ip_address_id = azurerm_public_ip.firewall_mgmt_pip.id
}


}

# Azure Firewall Management IP Configuration        
data "azurerm_subnet" "firewall_management" {
  name                 = "AzureFirewallManagementSubnet"
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = var.resource_group_name
}