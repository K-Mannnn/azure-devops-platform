terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-test"
  location = "westus"

  tags = {
    environment  = "dev"
    owner        = "yourname"
    project      = "devops-evolution"
    week         = "3"
    managed-by   = "terraform"
  }
}