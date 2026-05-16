# 1. Fetch Subscription Data
data "azurerm_subscription" "current" {}


# 4. Definition: Deny Public IPs
resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP creation except approved infrastructure"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/publicIPAddresses"
        },
        {
            #exception to allow only specific public IPs for approved infrastructure like Azure Firewall and Bastion Host. This ensures that while we block the creation of unauthorized public IPs, we still allow necessary ones for critical services to function properly.
          not = {
            anyOf = [
              {
                field  = "name"
                equals = "pip-bastion"
              },
              {
                field  = "name"
                equals = "pip-azure-firewall"
              },
              {
                field  = "name"
                equals = "pip-azure-firewall-mgmt"
              }
            ]
          }
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}

# Apply Public IP Deny Policy to Subscription
resource "azurerm_subscription_policy_assignment" "block_public_ips" {
  name                 = "public-ip-block"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  location             = var.location
}

# policy that denies attaching public IPs in subscription. modify similar to the above before uncomenting
/*
resource "azurerm_policy_definition" "deny_nic_with_public_ip" {
  name         = "deny-nic-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny NICs with Public IPs"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/networkInterfaces"
        },
        {
          field  = "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id"
          exists = true
        }
      ]
    }
    then = {
      effect = "allow"
    }
  })
}

# assigning policy
resource "azurerm_subscription_policy_assignment" "deny_nic_public_ip" {
  name                 = "deny-nic-public-ip-assignment"
  display_name         = "Deny NICs with Public IPs"
  policy_definition_id = azurerm_policy_definition.deny_nic_with_public_ip.id
  subscription_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  location             = azurerm_resource_group.rg.location
}
*/