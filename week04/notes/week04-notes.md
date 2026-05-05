## W4D1 — Azure Container Registry

Full commands in week4-manual-runbook.md.

### Key things I understood today

- ACR is a private Docker Hub inside your Azure subscription.
  Images built locally get pushed here. AKS pulls from here in
  Act 3 using Managed Identity — no credentials stored anywhere
  in the chain.

- admin_enabled = false is a security control not a preference.
  The ACR admin user has full push/pull access — a stolen
  credential compromises the entire registry. Managed Identity
  is the correct pattern. No credential exists to steal or rotate.

- Immutable tags are non-negotiable outside local development:
  vote:v0.1.0-a3f9c2d — permanently addressable, rollback by
  changing the tag reference, every deployment traceable to a
  git commit.
  vote:latest — overwritten on every push, no rollback, no audit
  trail. The pitfall on the card is real — a team couldn't roll
  back during a critical incident because latest had been
  overwritten with the broken version.

- Image layers — each Docker instruction creates a read-only
  layer. Layers are cached and shared between images. Move
  frequently changing instructions (COPY . .) to the bottom
  of the Dockerfile so stable layers (apt install, pip install)
  hit cache on every build. Build speed depends entirely on
  layer order.

- docker system df — shows disk usage by images, containers,
  and volumes. Important to understand what's actually consuming
  disk, especially in CI environments where images accumulate.

- ACR name must be globally unique and alphanumeric only —
  no hyphens. Named it acrdevopsevolutiondev to follow the
  pattern without hyphens.

- tag-image.sh — script that takes a service name, generates
  an immutable tag from git SHA, logs into ACR, builds and
  pushes. This script gets called by the CI pipeline in Act 2.
  Writing it now means it's ready when the pipeline needs it.

### What was added to Terraform today
- modules/acr/ — ACR module with admin_enabled=false
- rg-acr-dev resource group in dev environment
- rg-compute-dev and rg-data-dev added — were missing from
  Terraform since Week 2 when they were created manually

### What's coming
Today was infrastructure setup. The real Docker work starts
Week 5 — writing Dockerfiles, running the full stack with
Compose, fixing the Redis error that's been there since W1D1.
ACR is ready to receive images when that happens.