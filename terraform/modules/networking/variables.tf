variable "environment" {
  description = "Environment name — dev, staging, or prod"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus"
}

variable "vnet_address_space" {
  description = "VNet address space CIDR"
  type        = string
}

variable "subnet_cidrs" {
  description = "Map of subnet names to CIDR ranges"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "devops-evolution"
}