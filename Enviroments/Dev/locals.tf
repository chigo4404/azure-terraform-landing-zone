
locals {
  prefix = "${var.client_name}-${var.environment}"

  resource_group_name = "rg-${local.prefix}"

  hub_vnet_name = "vnet-hub-${local.prefix}"

  spoke_vnet_name = "vnet-spoke-${local.prefix}"

  private_endpoint_name = "pe-storage-${local.prefix}"

  storage_account_name = lower(
    replace("st${var.client_name}${var.environment}01", "-", "")
  )

  common_tags = merge(
    var.tags,
    {
      environment = var.environment
      managed_by  = "terraform"
    }
  )
}

