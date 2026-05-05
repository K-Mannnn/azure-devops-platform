# Module: acr

Creates an Azure Container Registry for private Docker image storage.

## Security
- admin_enabled = false — Managed Identity authentication only
- No admin credentials created or stored
- Pull scope map for read-only access

## Usage
```hcl
module "acr" {
  source              = "../../modules/acr"
  resource_group_name = "rg-acr-dev"
  location            = "westus"
  environment         = "dev"
  tags                = local.common_tags
}
```

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| resource_group_name | string | yes | Resource group name |
| location | string | yes | Azure region |
| environment | string | yes | Environment name |
| tags | map(string) | no | Resource tags |

## Outputs
| Name | Description |
|------|-------------|
| acr_id | ACR resource ID |
| acr_name | ACR name |
| acr_login_server | Login server URL |