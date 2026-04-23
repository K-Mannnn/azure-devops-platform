# Storage account
resource "azurerm_storage_account" "devops" {
  name                     = "devopsevolution${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.data.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false

  tags = local.common_tags
}

# Random suffix — storage account names must be globally unique
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Private endpoint for storage in snet-data
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.location
  subnet_id           = azurerm_subnet.data.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "pe-storage-connection"
    private_connection_resource_id = azurerm_storage_account.devops.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }
}