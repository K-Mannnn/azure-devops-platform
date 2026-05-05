# ADR 005 — Secrets Management via Azure Key Vault

## Status
Accepted

## Context
Application credentials (database passwords, API keys) were previously
stored in .env files. Toyota's connected vehicle breach in 2019 occurred
when a developer committed AWS access keys to a public GitHub repo —
keys valid for 5 years. Any credential that has ever been in a Git
repository should be considered compromised.

## Current state
Secrets stored in Azure Key Vault. Fetched at runtime via CLI.
Never written to disk. Never committed to Git.

## Target state (Act 2 Week 10)
Service Principal + client secret (today) →
Managed Identity (Act 2) — no credential exists to steal or rotate.
Pipeline fetches secrets using its own Managed Identity.
AKS pods mount secrets via CSI driver (Act 3).

## Decision
All application credentials stored in Key Vault from Week 4 onwards.
enable_rbac_authorization = true — modern RBAC model.
purge_protection_enabled = true — prevents accidental permanent deletion.
inject-secrets.sh fetches at runtime, exports to environment —
never writes to disk.

## Why Key Vault over .env files
- .env files get committed — it happens, always
- .env files get shared in Slack — it happens, always
- Key Vault audit logs record every access: who, when, from where
- In a security incident, the audit trail is the difference between
  knowing exactly what was exposed and not knowing

## Consequences
### Positive
- No credentials on disk or in Git ever
- Full audit trail of every secret access
- Centralised rotation — change once, all consumers get the new value
- RBAC controls who can read which secrets

### Negative
- Requires Azure login to fetch secrets locally
- Soft delete means vault names can't be reused immediately
- Additional latency fetching secrets at startup
- purge_protection means accidental vault deletion is hard to recover from