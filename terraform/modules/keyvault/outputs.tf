output "keyvault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.kv.id
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.kv.vault_uri
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.kv.name
}