# azure-devops-platform
Devops Learning Journey



## W3 - Terraform 

## Getting Started

### Prerequisites
- Azure CLI installed and logged in (`az login`)
- Terraform installed via tfenv (`brew install tfenv`)
- Contributor access to an Azure subscription

### First time setup
1. Clone the repository
2. Bootstrap remote state storage:
```bash
   ./week03/scripts/bootstrap-state.sh
```
3. Update `terraform/week03/main.tf` with the storage account name from bootstrap output
4. Initialise Terraform:
```bash
   cd terraform/week03
   terraform init
```
5. Review the plan:
```bash
   terraform plan
```
6. Apply:
```bash
   terraform apply
```

### End of session
Always run the cleanup script before closing:

terraform destroy

### State file
State is stored in Azure Blob Storage — never commit `terraform.tfstate` to Git.
Access requires Azure login with appropriate permissions.