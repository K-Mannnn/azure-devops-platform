
#!/bin/bash


echo "=== Infrastructure Health Check ==="
echo "Time: $(date '+%Y-%m-%d %H:%M:S')"

echo ""

echo "--- Resource Groups ---"

RG_LIST=(
  "rg-acr-dev"
  "rg-compute-dev"
  "rg-data-dev"
  "rg-monitoring-dev"
  "rg-networking-dev"
  "rg-terraform-state"
)

for RG in "${RG_LIST[@]}"; do
  if az group show --name "$RG" >/dev/null 2>&1; then
    echo "$RG: exists"
  else
    echo "$RG: NOT FOUND"
  fi
done

echo ""

#!/bin/bash

echo ""

# --- ACR ---
ACR_NAME="acrdevopsevolutiondev"

if ACR_SKU=$(az acr show --name "$ACR_NAME" --query sku.name -o tsv 2>/dev/null); then
  echo "# --- ACR ---"
  echo "# ✅ $ACR_NAME    $ACR_SKU SKU"
else
  echo "# --- ACR ---"
  echo "# ❌ $ACR_NAME    NOT FOUND"
fi

echo ""


# --- Key Vault ---
KV_NAME="kv-devopsevolution-dev"

if KV_SECRETS=$(az keyvault secret list --vault-name "$KV_NAME" --query "length(@)" -o tsv 2>/dev/null); then
  echo "# --- Key Vault ---"
  echo "# ✅ $KV_NAME    $KV_SECRETS secrets"
else
  echo "# --- Key Vault ---"
  echo "# ❌ $KV_NAME    NOT FOUND"
fi

echo ""


# --- Log Analytics ---
LAW_NAME="law-devops-dev"
RG_NAME="rg-monitoring-dev"

if RETENTION=$(az monitor log-analytics workspace show \
  --resource-group "$RG_NAME" \
  --workspace-name "$LAW_NAME" \
  --query retentionInDays -o tsv 2>/dev/null); then

  echo "# --- Log Analytics ---"
  echo "# ✅ $LAW_NAME    ${RETENTION} days retention"
else
  echo "# --- Log Analytics ---"
  echo "# ❌ $LAW_NAME    NOT FOUND"
fi

echo ""


# --- Terraform State ---
STATE_ACCOUNT="tfstatedevopsevolution"   # example
STATE_CONTAINER="tfstate"

if az storage container show \
  --name "$STATE_CONTAINER" \
  --account-name "$STATE_ACCOUNT" >/dev/null 2>&1; then

  echo "# --- Terraform State ---"
  echo "# ✅ remote state reachable"

  if [ -z "$(find . -name "*.tfstate" 2>/dev/null)" ]; then
    echo "# ✅ no local tfstate files found"
  else
    echo "# ⚠️ local tfstate files exist"
  fi
else
  echo "# --- Terraform State ---"
  echo "# ❌ remote state NOT reachable"
fi

echo ""

# =============================
# --- FINAL RESULT ---
# =============================

echo "=== RESULT: HEALTHY ==="
echo "=============================="

