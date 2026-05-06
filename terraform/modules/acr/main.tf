resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_container_registry_scope_map" "pull" {
  name                    = "pull-scope"
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = var.resource_group_name

  actions = [
    "repositories/*/content/read",
    "repositories/*/metadata/read"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "diag-acr-${var.environment}"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}