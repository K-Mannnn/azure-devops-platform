# Week 2 — Azure mental model

## Day 1 — Subscriptions, Resource Groups, and Regions

### Commands run

az account show --query tenantId

* to show tenant id in Azure CLI. 

az account show --query "{name:name, id:id, state:state}"

* to show subscriptions name, id and status

az group list --output table

* to show a list of resource groups under current subscription, current output:

        rg-devops-wus1    westus      Succeeded
        NetworkWatcherRG  westus      Succeeded

az resource list \
  --resource-group rg-devops-w1 \
  --output table

* to Show whats under resource group rg-devops-wus1. 


# Creating 3 new resource groups separated by resource lifecycle.

# Networking — long-lived, rarely deleted
az group create \
  --name rg-networking \
  --location westus \
  --tags environment=dev owner=yourname project=devops-evolution week=2 managed-by=manual

# Compute — VMs, AKS — frequently recreated
az group create \
  --name rg-compute \
  --location westus \
  --tags environment=dev owner=yourname project=devops-evolution week=2 managed-by=manual

# Data — storage, databases — never delete casually
az group create \
  --name rg-data \
  --location westus \
  --tags environment=dev owner=yourname project=devops-evolution week=2 managed-by=manual


# Reconfirming resource groups list

az group list --output table

* current output

    Name              Location    Status
    ----------------  ----------  ---------
    rg-devops-wus1    westus      Succeeded
    NetworkWatcherRG  westus      Succeeded
    rg-networking     westus      Succeeded
    rg-compute        westus      Succeeded
    rg-data           westus      Succeeded


# Pricing Calculator

* Hourly price for existing Ubuntu Standard_B2pts_v2 VM in West US region = US$ 0.01 
   
    or US$7.30 /month if left running the whole month.  

* Standard 32 GB HDD = US$1.54 / month

* IP Address: 


    Static IP address: 
    Standard (ARM) = US$3.65 /month
    Basic (Classic) = US$2.63 / month

    Dynamic IP address: 
    Standard (ARM) = US$0.00 /month
    Basic (Classic) = US$0.00 / month

