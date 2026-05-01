
# Week 3 Day 1-3 — flat Terraform, pre-module refactor
# Superseded by terraform/environments/dev in W3D4
# Kept for reference — shows evolution from flat to modular structure


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatedevopsevolution"
    container_name       = "tfstate"
    key                  = "act1/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}