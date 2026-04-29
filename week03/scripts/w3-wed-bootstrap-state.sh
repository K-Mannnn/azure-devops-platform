#!/bin/bash
# Bootstrap Terraform remote state storage
# Run once before terraform init
# Idempotent — safe to run multiple times

set -e

RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="tfstatedevopsevolution"
CONTAINER_NAME="tfstate"
LOCATION="westus"

echo "=== Bootstrapping Terraform State Storage ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Create resource group if it doesn't exist
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags environment=shared managed-by=manual project=devops-evolution \
  --output none && echo "Resource group: $RESOURCE_GROUP"

# Create storage account if it doesn't exist
echo "Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --output none && echo "Storage account: $STORAGE_ACCOUNT"

# Enable versioning
echo "Enabling versioning..."
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true \
  --output none && echo "Versioning: enabled"

# Enable soft delete — 30 day retention
echo "Enabling soft delete..."
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --delete-retention-days 30 \
  --enable-delete-retention true \
  --output none && echo "Soft delete: 30 days"

# Create container
echo "Creating container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login \
  --output none && echo "Container: $CONTAINER_NAME"

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Add this to your backend configuration:"
echo ""
echo "  backend \"azurerm\" {"
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    key                  = \"act1/terraform.tfstate\""
echo "  }"
echo ""
echo "Then run: terraform init -migrate-state"