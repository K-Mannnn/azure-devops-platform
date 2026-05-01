terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatedevopsevolution"
    container_name       = "tfstate"
    key                  = "dev/networking.tfstate"
  }
}