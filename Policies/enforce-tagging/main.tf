
# 1. Fetch Subscription Data
data "azurerm_subscription" "current" {}

# 2. Definition: Require Tags. curently set to allow for testing other policies. Change to 'deny' when ready to enforce tags.
/* ##temporarily commenting out the tag policy to avoid deployment issues while testing other policies. Uncomment when ready to enforce tags.
# 2. Definition: Require Tags
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Tags on Resources"

  policy_rule = jsonencode({
    if = {
      anyOf = [
        { field = "tags['environment']", exists = false },
        { field = "tags['owner']",       exists = false }
      ]
    }
    then = { effect = "deny" } # ARCHITECT FIX: Changed 'allow' to 'deny'
  })
}

# 3. Assignment: Apply the Tag Policy to the Subscription
resource "azurerm_subscription_policy_assignment" "audit_tags" {
  name                 = "tag-enforcement"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  location             = var.location
}
*/