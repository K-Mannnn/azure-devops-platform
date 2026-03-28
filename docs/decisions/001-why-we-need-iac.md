# ADR 001 — Adopt Infrastructure as Code

## Status
Accepted

## Context
Manual provisioning of virtual machines in Azure has led to inconsistent and
unreproducible environments.

Over multiple attempts to recreate the `vm-voting-app` environment (W1D3),
the process took ~40 minutes each time and resulted in several deviations:
- Different Ubuntu images were selected
- VM naming was inconsistent or forgotten
- Commands were mis-typed or executed in the wrong order
- Azure-specific issues varied between attempts due to slight differences in configuration

This has effectively created "snowflake servers" — environments that are unique,
manually configured, and difficult to reproduce.

In the event of failure, recovery is:
- Time-consuming
- Error-prone
- Dependent on human memory rather than a reliable source of truth

## Decision
Adopt Infrastructure as Code (IaC) using Terraform for all infrastructure
provisioning from Week 3 onwards.

All Azure resources (VMs, networking, etc.) will be defined declaratively in code
and stored in version control. Manual provisioning via the Azure Portal or CLI
will be avoided except for initial setup or emergencies.

## Consequences

### Positive
- Infrastructure becomes reproducible and consistent across environments
- Environment setup time is reduced and predictable
- Eliminates reliance on memory or manual steps
- Changes are version controlled and auditable
- Reduces configuration drift between environments

### Negative
- Learning curve associated with Terraform and HCL
- Additional complexity in managing Terraform state
- Initial time investment required to write and structure IaC modules from scratch while learning. 
- Not sure what sort of opeartional issues Iac produces and how to debug them


## Notes
This decision is driven by repeated failures and inconsistencies observed during
manual VM provisioning, highlighting the need for a more reliable and automated approach.