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



### W3D3 -- Rebuild everything from week02 using terraform. 

cd terraform/week03
touch variables.tf locals.tf network.tf outputs.tf terraform.tfvars

- created file structure to segment differnet parts of the infrastructure for better readibility and scalability.
- Note: Terraform doesn’t care about file names—everything in a directory is merged into one configuration.

# created the vaiables in variable.tf file

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westus"

  validation {
    condition     = contains(["westus", "westus2", "uksouth", "eastus"], var.location)
    error_message = "Location must be one of: westus, westus2, uksouth, eastus."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "devops-evolution"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "yourname"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Map of subnet names to CIDR ranges"
  type        = map(string)
  default = {
    mgmt = "10.0.0.0/27"
    app  = "10.0.1.0/24"
    data = "10.0.2.0/24"
    aks  = "10.0.3.0/23"
  }
}

* Tested with the following command:

terraform plan -var="environment=production"

- Got error " Environment must be one of: dev, staging, prod."

# Created locals.tf

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

# Created network.tf

# Resource group
resource "azurerm_resource_group" "networking" {
  name     = "rg-networking"
  location = var.location
  tags     = local.common_tags
}

# VNet
resource "azurerm_virtual_network" "devops" {
  name                = "vnet-devops"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  address_space       = [var.vnet_address_space]
  tags                = local.common_tags
}

# Subnets
resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["mgmt"]]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["app"]]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["data"]]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = [var.subnet_cidrs["aks"]]
}

# NSG — snet-app
resource "azurerm_network_security_group" "app" {
  name                = "nsg-snet-app"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  tags                = local.common_tags

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# NSG — snet-data
resource "azurerm_network_security_group" "data" {
  name                = "nsg-snet-data"
  resource_group_name = azurerm_resource_group.networking.name
  location            = azurerm_resource_group.networking.location
  tags                = local.common_tags

  security_rule {
    name                       = "AllowPostgresFromApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.subnet_cidrs["app"]
    destination_address_prefix = "*"
  }
}

# NSG associations
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}


### Created outputs.tf

output "vnet_id" {
  description = "VNet resource ID"
  value       = azurerm_virtual_network.devops.id
}

output "vnet_address_space" {
  description = "VNet address space"
  value       = azurerm_virtual_network.devops.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    mgmt = azurerm_subnet.mgmt.id
    app  = azurerm_subnet.app.id
    data = azurerm_subnet.data.id
    aks  = azurerm_subnet.aks.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    app  = azurerm_network_security_group.app.id
    data = azurerm_network_security_group.data.id
  }
}

## Added private DNS to network.tf 

# Private DNS Zone — internal service discovery
resource "azurerm_private_dns_zone" "internal" {
  name                = "devops-lab.internal"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.common_tags
}

# Link Private DNS Zone to VNet with auto-registration
resource "azurerm_private_dns_zone_virtual_network_link" "internal" {
  name                  = "link-vnet-devops"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.devops.id
  registration_enabled  = true
  tags                  = local.common_tags
}

# Private DNS Zone — storage private endpoint
resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.common_tags
}

# Link storage DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "link-storage"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = azurerm_virtual_network.devops.id
  registration_enabled  = false
  tags                  = local.common_tags
}


## Added storage.tf for storage account

# Storage account
resource "azurerm_storage_account" "devops" {
  name                     = "devopsevolution${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.data.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false

  tags = local.common_tags
}

# Random suffix — storage account names must be globally unique
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Private endpoint for storage in snet-data
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.location
  subnet_id           = azurerm_subnet.data.id
  tags                = local.common_tags

  private_service_connection {
    name                           = "pe-storage-connection"
    private_connection_resource_id = azurerm_storage_account.devops.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
  }
}

## Added rg-compute and rg-data to network.tf

resource "azurerm_resource_group" "compute" {
  name     = "rg-compute"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "data" {
  name     = "rg-data"
  location = var.location
  tags     = local.common_tags
}

## Added random proider to mmain.tf 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

### Moment of Truth

terraform init
terraform plan

- can see an enormous list of resources to be created in the plan, especially a long list under storage account

terraform apply 

* Magic!! Created all that in 5 mins, what took me a whole week last week. 

terraform destroy

* Even more importantly -- destroyed everything in a few minutes. 


### W3 D3 - - Remote State and State Locking — Production Terraform

# Creating a bash script to create the following: 
- Storage account for terraform state
- Create a container for tf state files
- enable versioning
- enable soft delete 30 days

script can be found in ./scripts/w3-wed-bootstrap-state.sh

# Creating terraform remote backend: 

Added the following to main.tf: 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatedevopsevolution"
    container_name       = "tfstate"
    key                  = "act1/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

terraform init

terraform plan

terraform apply 

# To test state locking: 

- From terminal window 1
terraform apply

- From terminal window 2 (immediately after the above)
terraform apply

- second terminal window output: 
 Error: Error acquiring the state lock
│ 
│ Error message: state blob is already locked
│ Lock Info:
│   ID:        01989724-625c-af9a-4645-a333d432a305
│   Path:      tfstate/act1/terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       kiran@kiranpals-MBP.lan
│   Version:   1.14.9
│   Created:   2026-04-29 21:27:23.551257 +0000 UTC
│   Info:      
│ 
│ 
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.

- proves state lock is working as intended. 



### W3D4 -- Terraform Modules — Reusable Infrastructure

Archive the existing flat terraform structure, add the following to existing main.tf at top as comment. 

- Week 3 Day 1-3 — flat Terraform, pre-module refactor
- Superseded by terraform/environments/dev in W3D4
- Kept for reference — shows evolution from flat to modular structure

# Create new terrafrom folder structure: 

terraform/
  modules/
    networking/
      main.tf        ← all networking resources
      variables.tf   ← typed inputs
      outputs.tf     ← exposed values
      README.md      ← required
  environments/
    dev/
      main.tf        ← calls networking module with dev values
      outputs.tf
      backend.tf     ← dev state key
    staging/
      main.tf        ← same module, different values
      outputs.tf
      backend.tf     ← staging state key


* create each file using infrastructure layout from previous week: 

# Dev
cd terraform/environments/dev
terraform init
terraform plan
terraform apply

# Staging
cd ../staging
terraform init
terraform plan
terraform apply

# Verify in Portal — you should see:

- rg-networking-dev with dev resources
- rg-networking-staging with staging resources
- Two separate state files in the tfstate container: dev/networking.tfstate and staging/networking.tfstate

