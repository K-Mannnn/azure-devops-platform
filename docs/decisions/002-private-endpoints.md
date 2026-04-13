# ADR 002 — Use Private Endpoints over Public Access

## Status
Accepted

## Context
Storage account created with public endpoint by default. Any IP on the
internet can attempt to reach it. Temporary IP allowlists become permanent.
A fintech startup left their Azure SQL public endpoint open and suffered
a breach 18 months later. The word 'temporary' in infrastructure is dangerous.

## Decision
All Azure PaaS services (storage, databases, Key Vault) accessed via
Private Endpoints from Week 2 onwards. Public network access disabled
at the service level.

## Consequences

### Positive
- Service has no public endpoint — not reachable from internet at all
- Same FQDN resolves to private IP inside VNet, public IP outside
  (public access disabled so outside resolution is irrelevant)
- Removes entire class of attack surface

### Negative
- Private Endpoint costs ~£0.01/hour per endpoint
- Requires Private DNS Zone setup for transparent resolution
- Adds complexity to VNet design — must plan subnet space for endpoints

## Service Endpoint vs Private Endpoint
Service Endpoint: VNet traffic to Azure service stays on Azure backbone.
Service still has a public endpoint — just restricted to VNet traffic.
Private Endpoint: Service gets a private IP inside your VNet.
No public endpoint required. Correct modern pattern.