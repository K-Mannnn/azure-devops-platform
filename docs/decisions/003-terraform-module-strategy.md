# ADR 003 — Terraform Module Strategy

## Status
Accepted

## Context
Flat Terraform with all resources in one folder works for a single
environment. Adding staging required either duplicating all code or
restructuring. Duplicated code diverges — staging had different NSG
rules from dev within weeks in the card's pitfall example. Testing
results became meaningless.

## Decision
Extract reusable infrastructure into modules under terraform/modules/.
Each environment under terraform/environments/ calls modules with
environment-specific values. Each environment has its own state file.

## Module boundaries
Boundaries follow organisational ownership:
- networking: owned by network/platform team
- compute: owned by applications team (coming in Act 3)
- data: owned by DBA/data team (coming in Act 3)

## Adding a new environment
1. Create terraform/environments/{env}/main.tf
2. Call the networking module with environment-specific CIDRs
3. Configure a unique backend state key: {env}/networking.tfstate
4. terraform init && terraform apply
Total time: ~5 minutes.

## Consequences

### Positive
- Structural consistency enforced — staging is always identical to dev
- New environment is a 5-minute task
- Changes to module propagate to all environments on next apply
- Independent state — dev changes cannot affect staging

### Negative
- Module changes affect all environments simultaneously — breaking
  changes must be tested carefully
- More folder depth to navigate
- Module versioning becomes important at scale (not implemented yet)