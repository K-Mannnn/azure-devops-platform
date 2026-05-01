# Azure DevOps Platform

A 36-week hands-on programme building production-grade Azure 
infrastructure from scratch — from a manually provisioned VM 
to a fully automated, observable, secure cloud platform.

**Stack:** Azure · Terraform · Docker · Kubernetes · CI/CD · Bash  
**App:** dockersamples/example-voting-app — evolved throughout  
**Goal:** DevOps / Cloud / Platform Engineer

---

## Repository Structure

```
├── terraform/
│   └── week03/              # VNet, subnets, NSGs, DNS, storage as code
├── docs/
│   ├── architecture-evolution.md
│   ├── azure-mental-model.md
│   ├── networking-layers.md
│   ├── snowflake-problem.md
│   ├── progress.md
│   └── decisions/
│       ├── 001-why-we-need-iac.md
│       └── 002-private-endpoints.md
├── week01/
│   ├── week1-manual-runbook.md
│   ├── notes/week01-notes.md
│   └── scripts/
│       ├── w1-mon-system-state.sh      # Remote VM system state
│       ├── w1-wed-health-check.sh      # Voting app health check
│       └── w1-fri-vm-deallocate.sh     # Auto-deallocate on threshold
├── week02/
│   ├── week2-manual-runbook.md
│   ├── notes/week02-notes.md
│   └── scripts/
│       ├── w2-mon-azure-resource-inventory.sh  # Azure resource inventory
│       ├── w2-wed-subnet-calc.sh               # CIDR subnet calculator
│       └── w2-fri-DNS-debug.sh                 # DNS debug toolkit
└── week03/
    ├── week3-manual-runbook.md
    ├── notes/week03-notes.md
    └── scripts/
        ├── w3-mon-terraform-state-inspector.sh  # Terraform state summary
        └── w3-wed-bootstrap-state.sh            # Bootstrap remote state
```

---

## Getting Started

### Prerequisites
```bash
# Azure CLI
az login && az account show

# Terraform via tfenv
brew install tfenv && tfenv install latest && tfenv use latest
```

### First time setup
```bash
# 1. Bootstrap remote state
./week03/scripts/w3-wed-bootstrap-state.sh

# 2. Update storage account name in terraform/week03/main.tf

# 3. Initialise and apply
cd terraform/week03
terraform init
terraform plan
terraform apply
```

---

## Current Architecture (Week 3)

Internet → NSG (80/443) → VNet 10.0.0.0/16
├── snet-mgmt  10.0.0.0/27
├── snet-app   10.0.1.0/24
├── snet-data  10.0.2.0/24  ← private only
└── snet-aks   10.0.3.0/23  ← Act 3

State: Azure Blob Storage — never commit `terraform.tfstate`  
DNS: devops-lab.internal — private zone, VNet only

---

## Documentation

| Document | Description |
|----------|-------------|
| docs/progress.md | Weekly progress log |
| docs/architecture-evolution.md | Architecture updated weekly |
| docs/networking-layers.md | Network reference |
| docs/decisions/ | Architecture Decision Records |
| weekXX/weekXX-manual-runbook.md | Session runbooks |
| weekXX/notes/ | Session notes |

---

## Programme Progress

- [x] Week 1 — Manual infrastructure, Linux, Bash
- [x] Week 2 — Azure networking, DNS, security
- [x] Week 3 — Terraform, remote state — in progress
- [ ] Week 4–6 — Docker, containers
- [ ] Act 2 — CI/CD pipelines
- [ ] Act 3 — Kubernetes on AKS
- [ ] Act 4 — Observability
- [ ] Act 5 — Security as Code
- [ ] Act 6 — Advanced platform
- [ ] Act 7 — Capstone & launch