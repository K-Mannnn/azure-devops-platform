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

