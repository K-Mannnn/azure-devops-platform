## W3D1 — Terraform Fundamentals

Full commands in terraform/week03 runbook.

### Key things I understood today

- Terraform is a 3-way reconciliation system — not a script:
  Desired state (code) vs state file (memory) vs real Azure infrastructure.
  Every terraform plan is a diff between all three. Every apply is just
  HTTP requests to the same ARM API as az commands and Portal clicks.

- The state file is sacred — not a log, not a history, not optional.
  It's Terraform's only memory of what it created. Lose it and Terraform
  loses the mapping between code and real infrastructure. It may try to
  recreate resources that already exist or fail to destroy ones it no
  longer knows about. Never commit it to Git, never edit it manually.

- serial is the state version number — not the apply count. It increments
  every time state changes. Important distinction when debugging state issues.

- The plan symbols matter — read them every time without exception:
  + create — low risk
  ~ update in place — medium risk
  - destroy — high risk, pause and think
  -/+ destroy and recreate — high risk, check what's being recreated

- Drift is normal in real environments — someone always changes something
  manually. terraform plan detects it, terraform apply corrects it.
  Proved this by adding a tag manually in the Portal — Terraform detected
  it immediately and removed it on next apply. This is why managed-by=terraform
  matters — if Terraform owns it, don't touch it manually.

- tfenv matters for the same reason nvm and pyenv matter — different projects
  pin different versions. .terraform-version enforces this per project.
  .terraform.lock.hcl locks the provider version.

- Provider vs resource vs data source:
  Provider = plugin that knows how to talk to Azure (azurerm)
  Resource = something Terraform creates and manages
  Data source = something Terraform reads but does not manage
  Each has a different lifecycle — important distinction for Week 3.

- TF_LOG=DEBUG reveals the raw HTTP requests to ARM. Terraform is not
  magic — it calls the same API as the Portal and CLI. Understanding this
  means you can debug it when it misbehaves.

- .gitignore must be updated before first apply — not after. Once state
  is committed it's in git history even if you delete the file later.

### What would happen if terraform.tfstate was deleted
Terraform loses the mapping to real infrastructure. On next apply it
would try to create resources that already exist — finding they exist
and crashing, or creating duplicates depending on the resource type.
Recovery requires terraform import to rebuild state manually — painful
and error-prone. Remote state with locking (W3D2) prevents the worst
of this.

### The managed-by tag shift
Week 1-2: managed-by=manual
Week 3+: managed-by=terraform
This single tag change signals to anyone looking at a resource whether
it is safe to destroy and recreate (terraform) or was hand-crafted
and needs care (manual). In enterprise environments this distinction
has real operational implications.