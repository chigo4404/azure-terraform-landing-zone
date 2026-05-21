resource "azurerm_firewall_policy" "fw_policy" {

  name                = "fw-policy-${var.environment}"

  resource_group_name = var.resource_group_name

  location            = var.location

  sku = "Premium"

  threat_intelligence_mode = "Alert"

  intrusion_detection {

    mode = "Alert"
  }

  dns {

    proxy_enabled = true
    servers = ["168.63.129.16"]# Azure DNS IP for Azure Firewall. later chane to custom DNS if needed
  }

  tags = var.tags
}

# =========================
# NETWORK RULES
resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {

  name               = "network-rule-group"

  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

  priority           = 100

  network_rule_collection {

    name     = "allow-east-west"

    priority = 100

    action   = "Allow"

    rule {

      name = "hub-to-spoke"

      protocols = ["Any"]

      source_addresses = ["10.0.10.0/24"]

      destination_addresses = ["10.1.1.0/24"]

      destination_ports = ["*"]
    }

    rule {

      name = "spoke-to-hub"

      protocols = ["Any"]

      source_addresses = ["10.1.1.0/24"]

      destination_addresses = ["10.0.10.0/24"]

      destination_ports = ["*"]
    }
  }
}