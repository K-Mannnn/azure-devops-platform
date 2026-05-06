# Module: monitoring

Creates a Log Analytics Workspace for centralised log aggregation.
Used by ACR, Key Vault, VMs, NSGs, and AKS throughout the programme.

## Usage
```hcl
module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = "rg-monitoring-dev"
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
| retention_in_days | number | no | Log retention 30-730 days |
| tags | map(string) | no | Resource tags |

## Outputs
| Name | Description |
|------|-------------|
| workspace_id | Workspace resource ID |
| workspace_name | Workspace name |
| primary_shared_key | Agent connection key (sensitive) |