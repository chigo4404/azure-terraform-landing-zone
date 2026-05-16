####################################################################################################

/*
# 1. Fetch current Azure Context
data "azurerm_client_config" "current" {}

# 2. Network Security Group (Firewall)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.client_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
}

# 3. Link NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}*/
