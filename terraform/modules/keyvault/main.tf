data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.project}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  tags                        = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-kv-${var.environment}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}