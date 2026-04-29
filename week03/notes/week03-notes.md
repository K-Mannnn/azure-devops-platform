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


### W3D2 -- Building with Terraform continues

# Terraform Basics — Quick Summary

1. File Structure (Why split .tf files?)

Terraform treats all .tf files in a directory as one configuration.

Splitting files like:

main.tf
variables.tf
locals.tf
network.tf
outputs.tf

is for humans, not Terraform.

* Why it’s done:
Improves readability
Reduces merge conflicts in teams
Groups related logic (network, variables, outputs)
Prepares for modular, scalable infrastructure

2. Terraform Language

Terraform uses HashiCorp Configuration Language (HCL).

Key traits:
Human-readable (cleaner than JSON)
Supports comments
Supports expressions and functions
JSON is supported, but rarely used

3. Variables (Inputs)

Example:

variable "location" {
  type    = string
  default = "westus"
}
What this means:
Defines an input called location
Can be used anywhere as:
var.location

4. Passing Values to Variables

Terraform doesn’t guess values—you provide them.

Common ways:
1. terraform.tfvars
location = "uksouth"

2. Custom file
terraform apply -var-file="dev.tfvars"

3. CLI
terraform apply -var="location=uksouth"

4. Environment variable
export TF_VAR_location="uksouth"
Priority Order (highest wins)
 - CLI > tfvars file > terraform.tfvars > env vars > default

5. Validation (Input Rules)

Example:

validation {
  condition     = contains(["westus", "uksouth"], var.location)
  error_message = "Invalid region"
}
Purpose:
Restricts allowed values
Fails early with clear errors

## Locals (Computed Values)

Locals are **internal values** you define inside Terraform to avoid repetition and keep things consistent.

They are written using a `locals` block:

```hcl
locals {
  resource_prefix = "${var.project}-${var.environment}"

  common_tags = {
    environment = var.environment
    owner       = var.owner
    project     = var.project
  }
}
```

---

### What locals are

* Values **computed from variables or other data**
* Used **only inside your Terraform config**
* Not provided by the user

---

### How to use them

Access locals like this:

```hcl
local.resource_prefix
local.common_tags
```

Example:

```hcl
name = "${local.resource_prefix}-vnet"
tags = local.common_tags
```

---

### Why use locals

#### 1. Avoid repetition

Instead of repeating:

```hcl
"${var.project}-${var.environment}"
```

You define it once:

```hcl
local.resource_prefix
```

---

#### 2. Keep things consistent

All resources use:

```hcl
tags = local.common_tags
```

No risk of missing or inconsistent tags.

---

#### 3. Centralize logic

If naming or tagging changes, update it in one place.

---

### Variables vs Locals

| Feature    | Variables (`var`) | Locals (`local`)        |
| ---------- | ----------------- | ----------------------- |
| Source     | Provided by user  | Defined in code         |
| Purpose    | Input             | Computed/reusable value |
| Mutability | Can be overridden | Fixed                   |

---

### Mental model

```text
Variables → Inputs (external)
Locals    → Helpers (internal)
```

---

### When to use locals

Use locals when you:

* Repeat the same value multiple times
* Build naming conventions
* Define shared tags
* Combine or transform variables

---

### Key takeaway

Locals make your Terraform:

* Cleaner
* DRYer (Don’t Repeat Yourself)
* Easier to maintain

They don’t add new functionality—they make your configuration **much easier to manage at scale**.


## Terraform Core Reference Rules

# Blocks vs References (most important rule)

* Definition block	    How you reference it
variable {}	          var.
locals {}	            local.
resource {}	          resource_type.name or resource_type.name.attribute
data {}	              data.<type>.<name>
output {}	            output.<name> (CLI/state reference)
module {}	            module.<name>

- This is how you reference values from different block, more notable ones are locals uses singular local. 
 -- e.g. 
 locals {
  resource_prefix = "${var.project}-${var.environment}"

  common_tags = {
    environment  = var.environment
    owner        = var.owner
    project      = var.project
    managed-by   = "terraform"
    week         = "3"
  }
}

- But when you reference it in terraform it will be 

tags = local.common_tags


# Terraform Outputs

Outputs are values that Terraform **returns after creating infrastructure**. They are used to expose useful information from your deployment.

---

## What outputs do

They define what Terraform should **display or export** after `terraform apply`.

Example:

```hcl id="o8k2qp"
output "resource_group_name" {
  value = azurerm_resource_group.networking.name
}
```

After apply:

```text id="v1m9qp"
resource_group_name = "rg-networking"
```

---

## Purpose of outputs

Outputs are used to:

* Show important values after deployment
* Pass data between modules
* Integrate with CI/CD pipelines
* Share IDs, IPs, or names of created resources

---

## Common examples

### Resource ID

```hcl id="t2p8mq"
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
```

---

### Public IP

```hcl id="x7k1ld"
output "vm_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}
```

---

### Subnet ID

```hcl id="q3m9sn"
output "app_subnet_id" {
  value = azurerm_subnet.app.id
}
```

---

## When outputs are shown

After running:

```bash id="k8v2qp"
terraform apply
```

Terraform prints:

```text id="m9v2qp"
Outputs:

vm_public_ip = 20.50.10.4
```

---

## How outputs are used

### 1. CLI visibility

Used to quickly see important deployment results.

---

### 2. Module communication

One module can expose outputs:

```hcl id="d2m8qp"
module.network.vnet_id
```

---

### 3. CI/CD pipelines

Used in automation tools (GitHub Actions, Azure DevOps) to pass values to later stages.

---

## Mental model

```text id="n7q2mv"
inputs  → variables
logic   → resources + locals
outputs → results after deployment
```

### W3D3 -- Remote State and State Locking — Production Terraform

* Creating a storage account for Terraform state, the Premise being there's one state file which is held and maintained rempotely and has a lock on it so only one person working on it at any given time. This will avoid multiple people running Terraform apply and creating duplicates or causing terraform apply to crash. 

-  Storage account itself is blob storage in this case. It needs versioning enabled so each terraform apply is run it creates a new state file with a version instead of overwriting it. This allows rolling back to previous versions easy if something goes wrong. 

- Storage account also need to have Soft delete enabled for 30 days. So If someone accidenatally deletes the storage account then the terraform state will be lost. Soft delete prohibits this loss by allowing a 30 days window to recover what was deleted. 

- Azure doesn't allow blobs at root of a storage account, so you need to create a container. so it looks like this: 
Storage Account (like a top-level bucket)
└── Container (like a folder / namespace)
    └── Blobs (files)

Storage Account: tfstateXXXXX
└── Container: tfstate
    └── act1/terraform.tfstate


* Creating Terraform remote backend -- this what turns terraform state from a local file to a remote, shared and safe infrastructure file. 


* Running Terraform apply 3 times didn;t create 3 different state files in blob storage with version numbers as I expected. Apparently the versioning is done in secret behind the scenes by Azure and is not visible by default. so what you get is a rollback capability but not file duplication with each terraform apply: 

* Ran Terraform destroy and deleted storage account mid run, this causes terraform to crash as it couldn't find the state file: 
  - do not destroy storage account manually where state file is kept while terraform is perfoming actions: 
  