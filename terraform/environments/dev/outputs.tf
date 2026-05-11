output "vnet_id" {
  value = module.networking.vnet_id
}

output "subnet_ids" {
  value = module.networking.subnet_ids
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.acr_login_server
}

output "acr_name" {
  description = "ACR name"
  value       = module.acr.acr_name
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.keyvault_uri
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = module.keyvault.keyvault_name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.monitoring.workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = module.monitoring.workspace_name
}