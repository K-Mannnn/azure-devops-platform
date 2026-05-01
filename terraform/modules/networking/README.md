# Module: networking

Creates the full networking stack for a single environment.

## Resources created
- Resource group (rg-networking-{environment})
- VNet with configurable address space
- Four subnets: mgmt, app, data, aks
- NSGs for app and data subnets with security rules
- NSG associations
- Private DNS zone (devops-lab.internal) with VNet link

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  environment        = "dev"
  location           = "westus"
  vnet_address_space = "10.0.0.0/16"

  subnet_cidrs = {
    mgmt = "10.0.0.0/27"
    app  = "10.0.1.0/24"
    data = "10.0.2.0/24"
    aks  = "10.0.3.0/23"
  }

  tags = {
    environment  = "dev"
    managed-by   = "terraform"
    project      = "devops-evolution"
  }
}
```

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| environment | string | yes | dev, staging, or prod |
| location | string | no | Azure region (default: westus) |
| vnet_address_space | string | yes | VNet CIDR |
| subnet_cidrs | map(string) | yes | Map of subnet names to CIDRs |
| tags | map(string) | no | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | VNet resource ID |
| vnet_name | VNet name |
| subnet_ids | Map of subnet names to IDs |
| nsg_ids | Map of NSG names to IDs |
| resource_group_name | Networking resource group name |
| private_dns_zone_id | Internal private DNS zone ID |

## Adding a new environment
1. Create `environments/{env}/main.tf`
2. Call this module with environment-specific CIDRs
3. Configure a unique backend state key
4. Run `terraform init && terraform apply`

Total time: ~5 minutes.