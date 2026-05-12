
#!/bin/bash

echo "Fetching secrets from Key Vault: kv-devopsevolution-dev"

POSTGRES_PASSWORD=$(az keyvault secret show \
  --vault-name kv-devopsevolution-dev \
  --name "postgres-password" \
  --query value -o tsv)

REDIS_PASSWORD=$(az keyvault secret show \
  --vault-name kv-devopsevolution-dev \
  --name "redis-password" \
  --query value -o tsv)

export POSTGRES_PASSWORD
export REDIS_PASSWORD

echo ""
echo "Secrets loaded into environment — not written to disk"
echo "POSTGRES_PASSWORD: [set]"
echo "REDIS_PASSWORD: [set]"



# Fetching secrets from Key Vault: kv-devopsevolution-dev

# Secrets loaded into environment — not written to disk
# POSTGRES_PASSWORD: [set]
# REDIS_PASSWORD: [set]