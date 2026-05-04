# ADR 004 — Destroy-and-Rebuild Test as Infrastructure Validation

## Status
Accepted

## Context
Terraform silently failing on resources requiring manual portal
configuration is a known failure mode. Teams discover this during
disaster recovery — when it is too late. A financial company's
rebuilt environment was missing three critical configurations,
discovered only under real incident conditions.

## Decision
Run a destroy-and-rebuild test at the end of every Act.
Everything that makes the environment functional must be in code.
Any manual step found is a bug — fix it before the test passes.

## Test results — Week 3

**Date:** 4/05/2026
**Time to rebuild:** 2 minutes 2 secs
**Manual steps found:** none
**Manual steps fixed:** none
**Result:** PASS 

## Commitment
- Run at end of every Act (Acts 1-7)
- Target times:
  - Act 1 (network only): under 15 minutes
  - Act 3 (network + AKS): under 20 minutes
  - Act 7 (full stack): under 30 minutes
- Any manual step found = test fails = fix required

## Consequences
### Positive
- Infrastructure reproducibility proved, not assumed
- Disaster recovery capability validated regularly
- Manual drift caught early when cheap to fix

### Negative
- Destroy-rebuild costs time each Act
- Azure resource deletion sometimes slow (~5 min)
- Test must be updated as infrastructure grows