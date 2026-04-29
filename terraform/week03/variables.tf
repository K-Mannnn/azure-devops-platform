variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westus"

  validation {
    condition     = contains(["westus", "westus2", "uksouth", "eastus"], var.location)
    error_message = "Location must be one of: westus, westus2, uksouth, eastus."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "devops-evolution"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "Kiran"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Map of subnet names to CIDR ranges"
  type        = map(string)
  default = {
    mgmt = "10.0.0.0/27"
    app  = "10.0.1.0/24"
    data = "10.0.2.0/24"
    aks  = "10.0.4.0/23"
  }
}
