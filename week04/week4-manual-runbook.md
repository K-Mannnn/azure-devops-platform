### Week4 day 1 - Day 1 Azure Container Registry — Your Private Image Store

week03/scripts/w3-wed-bootstrap-state.sh

- creates the terraform state storage, container etc. 

cd terraform/environment/dev

terraform init
terraform apply

terraform state list

- output
module.networking.azurerm_network_security_group.app
module.networking.azurerm_network_security_group.data
module.networking.azurerm_private_dns_zone.internal
module.networking.azurerm_private_dns_zone_virtual_network_link.internal
module.networking.azurerm_resource_group.networking
module.networking.azurerm_subnet.aks
module.networking.azurerm_subnet.app
module.networking.azurerm_subnet.data
module.networking.azurerm_subnet.mgmt
module.networking.azurerm_subnet_network_security_group_association.app
module.networking.azurerm_subnet_network_security_group_association.data
module.networking.azurerm_virtual_network.devops

terraform plan

- "No changes. Your infrastructure matches the configuration."

# Add ACR module to terraform. 

- New rep structure: 

terraform/
  week03
  modules/
    networking/     
    acr/            
  environments/
    dev/
    staging/

cd terraform/environment/dev

terraform init

terraform plan

terraform apply

- Apply complete! Resources: 5 added, 6 changed, 0 destroyed.


# Get the ACR login server

cd /path/to/voting-app

ACR=$(cd ../azure-devops-platform/terraform/environments/dev && terraform output -raw acr_login_server)
SHA=$(git rev-parse --short HEAD)
TAG="v0.1.0-${SHA}"

echo "Building: ${ACR}/vote:${TAG}"

docker build -t ${ACR}/vote:${TAG} .
docker push ${ACR}/vote:${TAG}


# Verify it's there

az acr repository show-tags \
  --name $(cd ~/path/to/azure-devops-platform/terraform/environments/dev && terraform output -raw acr_name) \
  --repository vote \
  --output table

Result
--------------
v0.1.0-63e9150



### W4D2 - Azure Key Vault — Secrets That Are Actually Secret

# Add KeyVault module to terraform

- New repo structure

terraform/
  week03
  modules/
    networking/     
    acr/    
    keyvault /        
  environments/
    dev/
    staging/

# Apply

terraform init
terraform plan
terraform apply

- Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

# Store your first secret

# Get your user object ID
USER_ID=$(az ad signed-in-user show --query id --output tsv)

# Get Key Vault resource ID
KV_ID=$(az keyvault show \
  --name "$(terraform output -raw keyvault_name)" \
  --query id \
  --output tsv)

# Assign Key Vault Secrets Officer role to yourself
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee $USER_ID \
  --scope $KV_ID


# Store your first secret

KV_NAME=$(terraform output -raw keyvault_name)

# Store database password
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "postgres-password" \
  --value "supersecretpassword123"

# Store Redis password placeholder
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "redis-password" \
  --value "redispassword123"

# Verify it exist

az keyvault secret list \
  --vault-name $KV_NAME \
  --output table


### W4D3 -- Azure Monitor and KQL

# Add Monitoring module to terraform

- This was added manually in week 2, now adding it to terraform. 

- New repo structure

terraform/
  week03
  modules/
    networking/     
    acr/    
    keyvault / 
    monitoring /      
  environments/
    dev/
    staging/


# Added Diagnostics settings to both ACR and KeyVault modules

monitoring module creates workspace → outputs workspace_id
       ↓
dev/main.tf passes workspace_id into acr module
dev/main.tf passes workspace_id into keyvault module
       ↓
acr module creates diagnostic setting pointing at workspace
keyvault module creates diagnostic setting pointing at workspace

# Apply to Azure

terraform init

terraform plan

terraform apply

- Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

# Add some data to the workspace

- create some ACR and Keyvault activity to send some logs to monitorint workspace. 

KV_NAME=$(terraform output -raw keyvault_name)
ACR_NAME=$(terraform output -raw acr_name)

# Generate Key Vault activity — list and show secrets
az keyvault secret list --vault-name $KV_NAME
az keyvault secret show --vault-name $KV_NAME --name postgres-password

# Generate ACR activity — login and list
az acr login --name $ACR_NAME
az acr repository list --name $ACR_NAME

# Wait 5-10 minutes for logs to flow to workspace
echo "Waiting for logs to flow..."
sleep 300
echo "Done — check the workspace"



*** Failed with ForbiddenByRBAC error ***

- The secrets and RBAC created in last session (W4D2) were destroyed as part of terraform destroy
- Recreate the RBAC assignment and secrets to store in Keyvault

# second attempt

KV_NAME=$(terraform output -raw keyvault_name)
ACR_NAME=$(terraform output -raw acr_name)

# Generate Key Vault activity — list and show secrets
az keyvault secret list --vault-name $KV_NAME
az keyvault secret show --vault-name $KV_NAME --name postgres-password

# Generate ACR activity — login and list
az acr login --name $ACR_NAME
az acr repository list --name $ACR_NAME

# Wait 5-10 minutes for logs to flow to workspace
echo "Waiting for logs to flow..."
sleep 300
echo "Done — check the workspace"

***. Failed with docker engine not running error ***

- Restart Docker locally

# Attempt 3

KV_NAME=$(terraform output -raw keyvault_name)
ACR_NAME=$(terraform output -raw acr_name)

# Generate Key Vault activity — list and show secrets
az keyvault secret list --vault-name $KV_NAME
az keyvault secret show --vault-name $KV_NAME --name postgres-password

# Generate ACR activity — login and list
az acr login --name $ACR_NAME
az acr repository list --name $ACR_NAME

# Wait 5-10 minutes for logs to flow to workspace
echo "Waiting for logs to flow..."
sleep 300
echo "Done — check the workspace"

*** Success ***

# Check the logs in workspace

- Azure portal >> WorkspaceNAME >> logs >> KQL mode

// Query 1 — Key Vault security audit
// When to use: daily security review, incident investigation
AzureDiagnostics
| where TimeGenerated > ago(48h)
| where ResourceType == "VAULTS"
| project TimeGenerated, OperationName, CallerIPAddress, ResultType
| order by TimeGenerated desc

// Query 2 — ACR login audit
// When to use: who logged into the registry and when
ContainerRegistryLoginEvents
| where TimeGenerated > ago(7d)
| project TimeGenerated, OperationName, CallerIpAddress, Identity
| order by TimeGenerated desc


// Query 3 — Azure resource metrics
// When to use: performance baseline across all resources
AzureMetrics
| where TimeGenerated > ago(24h)
| summarize AvgValue = avg(Average) by ResourceProvider, MetricName
| order by AvgValue desc

- review the result of each query above

terraform destroy

### W4D4 - Complete the Terraform Picture — All Services as Code

- Every single service has now been added as terraform code.

- output.tf 

# environments/dev/outputs.tf have all of these
output "acr_login_server"           # ✅ added D1
output "acr_name"                   # ✅ added D1
output "keyvault_uri"               # ✅ added D2
output "keyvault_name"              # ✅ added D2
output "log_analytics_workspace_id" # ✅ added D3
output "log_analytics_workspace_name" # ✅ added D3
output "subnet_ids"                 # ← check this exists
output "vnet_id"                    # ← check this exists

# Week 4 Rebuild test

terraform init

terraform plan

terraform apply

- All completed in 4 minutes

