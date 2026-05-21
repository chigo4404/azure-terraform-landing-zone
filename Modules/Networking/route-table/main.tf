/*
# This module creates route tables for the hub and spoke virtual networks.
resource "azurerm_route_table" "rt" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# Below is an example of a default route to the internet. allows everything to go to the internet. 
#In a real-world scenario, you would likely have more specific routes, such as routing traffic to on-premises networks via a VPN gateway 
#or to a firewall for inspection.

/*resource "azurerm_route" "default" {
  name                   = "default-route"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "Internet"
  }
*/
##############################################################################################################################


#####################################################################################################################################################
# ============================================================
# SPOKE ROUTE TABLE
# Forces spoke workload traffic through Azure Firewall
# ============================================================

resource "azurerm_route_table" "spoke_rt" {

  name                = "rt-${var.environment}"

  location            = var.location

  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Default route through Azure Firewall
# Force Internet Traffic Through Firewall
#This route will send all traffic to the firewall private IP for inspection and 
#then the firewall will decide where to route the traffic based on its rules.
resource "azurerm_route" "spoke_default_route" {

  name                   = "default-to-firewall"

  resource_group_name    = var.resource_group_name

  route_table_name       = azurerm_route_table.spoke_rt.name

  address_prefix         = "0.0.0.0/0"

  #next_hop_type          = "VirtualAppliance" #temp commnting out as firewall is not yet deployed. will uncomment once firewall is deployed and we have the private IP to reference.
  next_hop_type          = "Internet"

  next_hop_in_ip_address = var.firewall_private_ip
}

# Associate route table to SPOKE subnet

resource "azurerm_subnet_route_table_association" "spoke_assoc" {

  subnet_id = var.subnet_id

  route_table_id = azurerm_route_table.spoke_rt.id
}


# ============================================================
# HUB ROUTE TABLE
# Forces hub management traffic to spoke through firewall
# ============================================================

resource "azurerm_route_table" "hub_rt" {

  name                = "rt-hub-${var.environment}"

  location            = var.location

  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Hub-to-spoke inspected route
# Hub-to-Spoke Inspection Route
# Forces hub management subnet traffic to pass through firewall
# before reaching spoke workloads.

resource "azurerm_route" "hub_to_spoke_route" {

  name                   = "hub-to-spoke-firewall"

  resource_group_name    = var.resource_group_name

  route_table_name       = azurerm_route_table.hub_rt.name

  address_prefix         = "10.1.0.0/16"

  #next_hop_type          = "VirtualAppliance" #temp commnting out as firewall is not yet deployed. will uncomment once firewall is deployed and we have the private IP to reference.
  next_hop_type          = "Internet"

  next_hop_in_ip_address = var.firewall_private_ip
}

# Associate hub route table to management subnet

resource "azurerm_subnet_route_table_association" "hub_assoc" {

  subnet_id = var.hub_management_subnet_id

  route_table_id = azurerm_route_table.hub_rt.id
}