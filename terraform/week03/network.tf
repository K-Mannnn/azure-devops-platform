# Resource group
resource "azurerm_resource_group" "networking" {
  name     = "rg-networking"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "compute" {
  name     = "rg-compute"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "data" {
  name     = "rg-data"
  location = var.location
  tags     = local.common_tags
}

# VNet
resource "azurerm_virtual_network" "devops" {
  name                = "vnet-devops"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  address_space       = [var.vnet_address_space]
  tags                = local.common_tags
}

# Subnets
resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["mgmt"]]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["app"]]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["data"]]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["aks"]]
}

# NSG — snet-app
resource "azurerm_network_security_group" "app" {
  name                = "nsg-snet-app"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  tags                = local.common_tags

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# NSG — snet-data
resource "azurerm_network_security_group" "data" {
  name                = "nsg-snet-data"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  tags                = local.common_tags

  security_rule {
    name                       = "AllowPostgresFromApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.subnet_cidrs["app"]
    destination_address_prefix = "*"
  }
}

# NSG associations
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}


# Private DNS Zone — internal service discovery
resource "azurerm_private_dns_zone" "internal" {
  name                = "devops-lab.internal"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.common_tags
}

# Link Private DNS Zone to VNet with auto-registration
resource "azurerm_private_dns_zone_virtual_network_link" "internal" {
  name                  = "link-vnet-devops"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.devops.id
  registration_enabled  = true
  tags                  = local.common_tags
}

# Private DNS Zone — storage private endpoint
resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.common_tags
}

# Link storage DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "link-storage"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = azurerm_virtual_network.devops.id
  registration_enabled  = false
  tags                  = local.common_tags
}