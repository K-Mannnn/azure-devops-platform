# Azure Mental Model

## Hierarchy
Tenant → Management Groups → Subscription → Resource Groups → Resources

## What each level controls
- Tenant: identity — users, groups, authentication
- Management Groups: policy and RBAC across multiple subscriptions
- Subscription: billing boundary — all costs roll up here
- Resource Group: lifecycle boundary — delete the group, delete everything in it
- Resource: individual service — VM, NSG, storage account

## Resource group structure — why separated by lifecycle
- rg-networking: VNet, NSG, DNS — long-lived, rarely deleted
- rg-compute: VMs, AKS — frequently created and destroyed
- rg-data: storage, databases — persistent, never delete casually

## ARM — Azure Resource Manager
Every portal click, CLI command, and Terraform apply calls the same
REST API. Terraform's azurerm provider is a structured wrapper around
these API calls. Understanding this demystifies what Terraform does —
it's not magic, it's just making ARM API calls reproducibly from code.

## Regions and availability zones
- Region: geographic area — West US, UK South
- Availability Zone: physically separate datacentre within a region
- Availability Set: logical grouping within one datacentre

## Tags — mandatory from Week 2
environment=dev
owner=[yourname]
project=devops-evolution
week=[current week]
managed-by=manual → changes to terraform in Week 3