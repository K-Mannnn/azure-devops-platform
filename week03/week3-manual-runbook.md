## W3D1 — Terraform Fundamentals

### Phase 1 — Installation via tfenv

```bash
brew install tfenv
tfenv install latest
tfenv use latest
terraform version
tfenv list-remote | head -20
```

tfenv manages Terraform versions per project — same concept as nvm
for Node or pyenv for Python. Prevents compatibility issues when
projects pin different versions.

---

### Phase 2 — Repo structure and version pinning

```bash
mkdir -p terraform/week03
cd terraform/week03
terraform version --json | jq -r '.terraform_version' > .terraform-version
```

.terraform-version — used by tfenv to enforce project-specific version.
If missing or invalid, tfenv fails resolution.

Git ignore setup — done before first apply:
```bash
cat >> ../../.gitignore << 'EOF'

# Terraform
**/.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
EOF
```

Why critical — terraform.tfstate contains sensitive infrastructure
mapping. .terraform/ contains downloaded provider binaries. Neither
belongs in version control. Must be added to .gitignore before the
first terraform apply — not after.

---

### Phase 3 — First configuration (main.tf)

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-test"
  location = "westus"

  tags = {
    environment = "dev"
    owner       = "yourname"
    project     = "devops-evolution"
    week        = "3"
    managed-by  = "terraform"
  }
}
```

Three blocks — three distinct concepts:
terraform {} → provider requirements and version constraints
provider {} → authentication and configuration for azurerm
resource {} → actual infrastructure to declare and manage

---

### Phase 4 — Terraform workflow

```bash
# Initialise — downloads provider plugin, locks version
terraform init

# Plan — compare desired state vs state file vs real Azure
terraform plan

# See raw ARM API calls
TF_LOG=DEBUG terraform plan 2>&1 | grep -A5 "HTTP request"

# Apply — execute the plan, update state file
terraform apply

# Destroy — remove all managed resources
terraform destroy
```

Plan output symbols — read every time without exception:
  + create          low risk
  ~ update in place medium risk
  - destroy         high risk — pause and think
  -/+ destroy and recreate — high risk, check what's being recreated

terraform init downloads the azurerm provider plugin — the code that
knows how to translate Terraform resources into ARM API calls.
.terraform.lock.hcl locks the provider version for consistency.

TF_LOG=DEBUG reveals raw HTTP requests to Azure ARM. Terraform calls
the same API as az commands and Portal clicks — it is not magic.
Understanding this enables debugging when Terraform misbehaves.

---

### Phase 5 — State file inspection

```bash
cat terraform.tfstate | jq .
terraform show
terraform state list
terraform state show azurerm_resource_group.test
```

Key fields in terraform.tfstate:
serial → state version number, increments on every state change
         NOT the apply count — important distinction
resources → array of everything Terraform manages
instances[].attributes → actual Azure API responses

The state file is Terraform's only memory of what it created.
If deleted — Terraform loses the mapping between code and real
infrastructure. May attempt to recreate existing resources causing
duplication or failure. Recovery requires terraform import — painful.
Never commit, never edit manually, never delete.

---

### Phase 6 — Drift simulation

Manual change: Portal → rg-terraform-test → Tags → added manually-added=true

```bash
# Detect drift
terraform plan
# Output: ~ update in place — Terraform detected tag added manually

# Restore desired state
terraform apply
# Result: manual tag removed, desired state enforced
```

Drift is normal in real environments. terraform plan detects when
real state differs from desired state. terraform apply corrects it.
If Terraform manages a resource, manual changes are temporary —
they will be overwritten on next apply. This is why managed-by=terraform
matters as a governance signal.

---

### Phase 7 — Destroy

```bash
terraform destroy
# - symbol confirms deletion
# type yes to confirm

# Verify state is empty
cat terraform.tfstate | jq .resources
# Expected output: []
```

After destroy, state file resources array is empty — Terraform knows
it destroyed everything. Serial number still increments.

---

### Issues encountered
None — session completed cleanly.

---

### Key principle
Infrastructure as Code means infrastructure is not managed directly.
It is declared, versioned, and continuously reconciled against real
state. Terraform enforces what the code says — not what someone
clicked in the Portal last Tuesday.