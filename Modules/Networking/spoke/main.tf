resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags

    lifecycle {
        prevent_destroy = true
    }

}

# =========================
# APPLICATION SUBNET
# =========================

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# =========================
# DATA SUBNET
# =========================

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

# =========================
# PRIVATE ENDPOINT SUBNET
# =========================

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.3.0/24"]

  private_endpoint_network_policies = "Disabled"
}

# =========================
# NSG ASSOCIATION
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = var.app_nsg_id
}

resource "azurerm_subnet_network_security_group_association" "data_assoc" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = var.data_nsg_id
}

/*
# NSG ASSOCIATION FOR PRIVATE ENDPOINTS SUBNET
resource "azurerm_subnet_network_security_group_association" "pe_assoc" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = var.pe_nsg_id
}
*/

# =========================

resource "azurerm_subnet_route_table_association" "app_rt" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = var.route_table_id
}