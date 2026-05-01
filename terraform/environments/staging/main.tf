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

  environment        = "staging"
  location           = "westus"
  vnet_address_space = "10.1.0.0/16"

  subnet_cidrs = {
    mgmt = "10.1.0.0/27"
    app  = "10.1.1.0/24"
    data = "10.1.2.0/24"
    aks  = "10.1.4.0/23"
  }

  tags = {
    environment = "staging"
    owner       = "yourname"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "3"
  }
}