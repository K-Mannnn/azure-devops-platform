# Module: keyvault

Creates an Azure Key Vault for secure secrets storage.

## Security decisions
- enable_rbac_authorization = true — modern RBAC model, not legacy Access Policies
- purge_protection_enabled = true — prevents accidental permanent deletion
- soft_delete_retention_days = 7 — minimum retention, recoverable window
- No secrets stored in this module — secrets managed separately

## Important
Key Vault names are globally unique. Deleted vaults enter soft-delete
state for 7-90 days — you cannot reuse the name during this period.
If destroy-rebuild fails on name conflict:
  az keyvault purge --name <vault-name> --location <region>

## Usage
```hcl
module "keyvault" {
  source              = "../../modules/keyvault"
  resource_group_name = "rg-data-dev"
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
| soft_delete_retention_days | number | no | Retention days (7-90) |
| tags | map(string) | no | Resource tags |

## Outputs
| Name | Description |
|------|-------------|
| keyvault_id | Key Vault resource ID |
| keyvault_uri | Key Vault URI |
| keyvault_name | Key Vault name |