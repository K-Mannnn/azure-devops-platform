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

module "networking" {
  source = "../../modules/networking"

  environment        = "dev"
  location           = "westus"
  vnet_address_space = "10.0.0.0/16"

  subnet_cidrs = {
    mgmt = "10.0.0.0/27"
    app  = "10.0.1.0/24"
    data = "10.0.2.0/24"
    aks  = "10.0.4.0/23"
  }

  tags = {
    environment = "dev"
    owner       = "yourname"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "3"
  }
}