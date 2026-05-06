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

# Compute resource group
resource "azurerm_resource_group" "compute" {
  name     = "rg-compute-dev"
  location = "westus"
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# Data resource group
resource "azurerm_resource_group" "data" {
  name     = "rg-data-dev"
  location = "westus"
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# ACR resource group
resource "azurerm_resource_group" "acr" {
  name     = "rg-acr-dev"
  location = "westus"
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# Monitoring resource group
resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring-dev"
  location = "westus"
  tags = {
    environment = "dev"
    owner       = "yourname"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# Networking module
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
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# ACR module
module "acr" {
  source              = "../../modules/acr"
  resource_group_name = azurerm_resource_group.acr.name
  location            = "westus"
  environment         = "dev"
  project             = "devopsevolution"
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# KeyVault module

module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = azurerm_resource_group.data.name
  location            = "westus"
  environment         = "dev"
  project             = "devopsevolution"
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}

# Monitoring module
module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = "westus"
  environment         = "dev"
  tags = {
    environment = "dev"
    owner       = "Kiran"
    project     = "devops-evolution"
    managed-by  = "terraform"
    week        = "4"
  }
}