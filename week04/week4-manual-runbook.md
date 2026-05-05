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

acr_login_server = "acrdevopsevolutiondev.azurecr.io"
acr_name = "acrdevopsevolutiondev"

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

