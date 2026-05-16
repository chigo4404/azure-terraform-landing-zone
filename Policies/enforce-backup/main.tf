
#####################
/*
data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "auto_backup_prod_vms" {

  name         = "auto-enable-prod-vm-backup"
  policy_type  = "Custom"
  mode         = "Indexed"

  display_name = "Automatically Enable Backup for Production VMs"


policy_rule = jsonencode({

  "if" = {
    "allOf" = [

      {
        "field" = "type"
        "equals" = "Microsoft.Compute/virtualMachines"
      },

      {
        "anyOf" = [

          {
            "field" = "tags.environment"
            "equals" = "prod"
          },

          {
            "field" = "tags.environment"
            "equals" = "production"
          }

        ]
      }

    ]
  },

  "then" = {

    "effect" = "DeployIfNotExists",

    "details" = {

      "type" = "Microsoft.RecoveryServices/backupprotecteditems",

      "roleDefinitionIds" = [
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
      ],

      "existenceCondition" = {
        "field" = "Microsoft.RecoveryServices/backupprotecteditems/policyId",
        "exists" = true
      },

      "deployment" = {

        "properties" = {

          "mode" = "incremental",

          "template" = {

            "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",

            "contentVersion" = "1.0.0.0",

            "parameters" = {

              "vmName" = {
                "type" = "string"
              },

              "vaultName" = {
                "type" = "string"
              },

              "policyId" = {
                "type" = "string"
              },

              "location" = {
                "type" = "string"
              }
            },

            "resources" = [

              {
                "type" = "Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems",

                "apiVersion" = "2023-01-01",

                "name" = "[concat(parameters('vaultName'), '/Azure/protectioncontainer;iaasvmcontainer;iaasvmcontainerv2;', resourceGroup().name, ';', parameters('vmName'), '/vm;iaasvmcontainerv2;', resourceGroup().name, ';', parameters('vmName'))]",

                "properties" = {

                  "protectedItemType" = "Microsoft.Compute/virtualMachines",

                  "policyId" = "[parameters('policyId')]",

                  "sourceResourceId" = "[resourceId('Microsoft.Compute/virtualMachines', parameters('vmName'))]"
                }
              }
            ]
          },

          "parameters" = {

            "vmName" = {
              "value" = "[field('name')]"
            },

            "vaultName" = {
              "value" = var.recovery_vault_name
            },

            "policyId" = {
              "value" = var.backup_policy_id
            },

            "location" = {
              "value" = "[field('location')]"
            }
          }
        }
      }
    }
  }
})
}

resource "azurerm_subscription_policy_assignment" "backup_assignment" {

  name                 = "auto-enable-prod-vm-backup"

  subscription_id      = data.azurerm_subscription.current.id

  policy_definition_id = azurerm_policy_definition.auto_backup_prod_vms.id

  location             = var.location

  enforce              = true

  identity {
    type = "SystemAssigned"
  }
}
*/
data "azurerm_subscription" "current" {}

data "azurerm_policy_definition" "builtin_vm_backup" {

  display_name = "Configure backup on virtual machines with a given tag to an existing recovery services vault in the same location"
}

resource "azurerm_subscription_policy_assignment" "backup_assignment" {

  name                 = "auto-enable-prod-vm-backup"

  subscription_id      = data.azurerm_subscription.current.id

  policy_definition_id = data.azurerm_policy_definition.builtin_vm_backup.id

  location             = var.location

  enforce              = true

  identity {
    type = "SystemAssigned"
  }

parameters = jsonencode({

  backupPolicyId = {
    value = var.backup_policy_id
  }

  effect = {
    value = "DeployIfNotExists"
  }

  inclusionTagName = {
    value = "environment"
  }

  inclusionTagValue = {
    value = ["production"]
  }

  vaultLocation = {
    value = var.location
  }
    
    backupPolicyId = {
      value = var.backup_policy_id
    }

    effect = {
      value = "DeployIfNotExists"
    }
  })
}

