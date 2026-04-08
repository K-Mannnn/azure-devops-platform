

#!/bin/bash
# Azure resource inventory




echo "=== Azure Resource Inventory ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Subscription: $(az account show --query name --output tsv)"



echo ""

echo "--- Resource Groups ---"
az group list | jq -r '.[]|[.name, .location, "[environment=\(.tags.environment), managed-by=\(.tags["managed-by"])]"] | @tsv'



echo ""

echo "--- Running VMs ---"

az vm list --show-details | jq -r '
.[] 
| select(.powerState=="VM running") 
| "\(.name)\t\(.resourceGroup)\t\(.powerState | ltrimstr("VM "))\t\(.hardwareProfile.vmSize)"
'

echo ""

echo "--- Summary ---"

# Count resource groups
rg_count=$(az group list --query 'length(@)' -o tsv)
echo "Total resource groups: $rg_count"

# Count running VMs
running_vms=$(az vm list --show-details \
  --query '[?powerState==`VM running`] | length(@)' \
  --output tsv)

echo "Running VMs: $running_vms"
echo "=============================="







