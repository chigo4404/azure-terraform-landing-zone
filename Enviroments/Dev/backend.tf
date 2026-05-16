#Configure Remote State for storing this entire code/terraform state in Az storage
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "chigo440412345g"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}