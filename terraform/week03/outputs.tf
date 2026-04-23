output "vnet_id" {
  description = "VNet resource ID"
  value       = azurerm_virtual_network.devops.id
}

output "vnet_address_space" {
  description = "VNet address space"
  value       = azurerm_virtual_network.devops.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    mgmt = azurerm_subnet.mgmt.id
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
    aks  = azurerm_subnet.aks.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    app  = azurerm_network_security_group.app.id
    data = azurerm_network_security_group.data.id
  }
}

output "private_dns_zone_id" {
  description = "Internal private DNS zone ID"
  value       = azurerm_private_dns_zone.internal.id
}