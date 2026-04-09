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



## Day 2 -- Azure Networking — VNet, Subnets, and the Security Boundary

* Diagram below explains the structure of Azure Vnet and components outside and how they are connected. 

                    🌍 Internet
                         │
                         ▼
              ┌─────────────────────┐
              │  Azure Edge /       │
              │  Platform Routing   │  (Managed by Azure)
              └─────────────────────┘
                         │
                         ▼
                🌐 Public Entry Points
        (Public IP / Load Balancer / App Gateway)
                         │
                         ▼
            ┌──────────────────────────────┐
            │   🔥 Azure Firewall (Hub)    │
            │   Central traffic control    │
            └──────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────────┐
        │        VNet (Your Network)         │
        │  :contentReference[oaicite:0]{index=0} │
        │                                    │
        │   ┌──────────────┐                 │
        │   │   Subnet A   │ (Web Tier)      │
        │   │──────────────│                 │
        │   │ NSG          │ 🔒              │
        │   │ UDR → FW     │ ➡️              │
        │   │ VM / App     │ 💻              │
        │   └──────────────┘                 │
        │                                    │
        │   ┌──────────────┐                 │
        │   │   Subnet B   │ (App Tier)      │
        │   │──────────────│                 │
        │   │ NSG          │ 🔒              │
        │   │ UDR          │ ➡️              │
        │   │ Services     │ ⚙️              │
        │   └──────────────┘                 │
        │                                    │
        │   ┌──────────────┐                 │
        │   │   Subnet C   │ (DB Tier)       │
        │   │──────────────│                 │
        │   │ NSG (strict) │ 🔒              │
        │   │ Private only │ 🚫🌐            │
        │   │ Database     │ 🗄️              │
        │   └──────────────┘                 │
        └────────────────────────────────────┘
                         │
                         ▼
         🔗 VNet Peering / VPN / ExpressRoute
                         │
                         ▼
              Other VNets / On-Premises

# CIDR

* CIDR (Classless Inter-Domain Routing) is a way of defining IP address ranges using the format below: 

    IP_address / prefix_length

    example - 10.0.0.0/16

    Here /16 means 16 bits out of the 32 available for an Ipv4 IP address are fixed for the network and remaining 16 are available. Hence 2^16 i.e. 65,536 IP addresses. 

    In Azure Virtual Network:

* Azure reserves 5 IPs per subnet
  So usable IPs in /24:    256 - 5 = 251 usable

* Network address & Broadcast address: 

  In a Subnet CIDR range, a network address is the first IP address and a Broadcast address is the last IP address.  

  example; In a Subnet with CIDR range 10.0.1.0/24, thenetwork address would be: 10.0.1.0 and the broadcast address would be: 10.0.1.255 

* Number of subnets available in a Vnet

  Formula: 2^(subnet bits - vnet bits)

  example How many /24 subnets can fit in a /16 vnet: so 2^(24-16) = 2^8 = 256

# Creating Azure VNet

az network vnet create \
  --name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.0.0/16 \
  --location westus \
  --tags environment=dev owner=yourname project=devops-evolution week=2 managed-by=manual

az network vnet list -o table

* Name         ResourceGroup    Location    NumSubnets    Prefixes     DnsServers    DDOSProtection    VMProtection
  -----------  ---------------  ----------  ------------  -----------  ------------  ----------------  --------------
  vnet-devops  rg-networking    westus      0             10.0.0.0/16                False

* DDos protection False here means you are on basic Azure plan and you only get basic level DDos protection. It can be upgraded to DDoS Protection Standard

# Created 4 subnets

# Management — small, /27, 27 usable Azure IPs
az network vnet subnet create \
  --name snet-mgmt \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.0.0/27

# App servers — /24, 251 usable Azure IPs
az network vnet subnet create \
  --name snet-app \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.1.0/24

# Databases — /24, 251 usable Azure IPs
az network vnet subnet create \
  --name snet-data \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.2.0/24

# AKS — /23, 507 usable Azure IPs
az network vnet subnet create \
  --name snet-aks \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.4.0/23

* verified all 4 exist: 

az network vnet subnet list \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --output table

# Created NSGs 

*  NSG for snet-app
az network nsg create \
  --name nsg-snet-app \
  --resource-group rg-networking \
  --tags environment=dev managed-by=manual

* Allow HTTP inbound from internet for nsg-snet-app
az network nsg rule create \
  --nsg-name nsg-snet-app \
  --resource-group rg-networking \
  --name AllowHTTP \
  --priority 100 \
  --protocol Tcp \
  --destination-port-range 80 \
  --source-address-prefixes Internet \
  --access Allow

* Allow HTTPS inbound from internet for nsg-snet-app
az network nsg rule create \
  --nsg-name nsg-snet-app \
  --resource-group rg-networking \
  --name AllowHTTPS \
  --priority 110 \
  --protocol Tcp \
  --destination-port-range 443 \
  --source-address-prefixes Internet \
  --access Allow

* NSG for snet-data
az network nsg create \
  --name nsg-snet-data \
  --resource-group rg-networking \
  --tags environment=dev managed-by=manual

* Allow PostgreSQL only from snet-app — not from internet,  This is to ensure database is only accessible from application subnet CIDR range i.e. any access from the internet to database will have to go via the application layer. 
az network nsg rule create \
  --nsg-name nsg-snet-data \
  --resource-group rg-networking \
  --name AllowPostgresFromApp \
  --priority 100 \
  --protocol Tcp \
  --destination-port-range 5432 \
  --source-address-prefixes 10.0.1.0/24 \
  --access Allow

# Associate NSGs to subnets: 

* Associate nsg-snet-app to snet-app
az network vnet subnet update \
  --name snet-app \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --network-security-group nsg-snet-app

* Associate nsg-snet-data to snet-data
az network vnet subnet update \
  --name snet-data \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --network-security-group nsg-snet-data

* Deployed a test VM to snet-app subnet.

curl -v http://<PUBLIC_IP>

* Connection timed out i.e. NSG is allowing traffic to port 80 as per the set rule however there's nothing listening on port 80 hence connection timed out. This should be ideally Connection refused if there was a service running on the vm listenting on VM. 

curl -v telnet://<PUBLIC_IP>:22

* connection timed out because NSG doesn't allow traffic on port 22. 


## Network Segmentation

### Why each subnet is sized the way it is

**snet-mgmt — 10.0.0.0/27 (27 usable IPs)**
Management only — Azure Bastion, jump box. Never more than a handful
of resources. A /27 gives 27 IPs which is plenty. Giving it a /24
would waste 251 IPs on a subnet that holds 3 things.

**snet-app — 10.0.1.0/24 (251 usable IPs)**
Application servers. As the app grows — multiple VMs, load balancers,
app service instances. A /24 gives room to scale without redesigning
the network.

**snet-data — 10.0.2.0/24 (251 usable IPs)**
Databases and storage endpoints. Databases multiply as applications
grow — PostgreSQL, Redis, analytics DB. Same reasoning as snet-app.

**snet-aks — 10.0.3.0/23 (507 usable IPs)**
Azure CNI mode allocates a real VNet IP to every pod, not just every
node. A small cluster with 3 nodes × 30 pods = 90 pod IPs + 3 node
IPs + 5 Azure reserved = 98 IPs minimum. Scale to 10 nodes × 30 pods
= 305 IPs. A /24 runs out fast. A /23 gives 507 — enough headroom to
scale without cluster migration.

---

### Why network segmentation matters

The NSG rule on snet-data:
  Allow port 5432 from 10.0.1.0/24 (snet-app) only
  Deny all other inbound

If the app layer gets compromised, an attacker inside snet-app can
only reach snet-data on port 5432 — exactly the same way the
legitimate app does. They cannot SSH into the database server, cannot
hit any other port, cannot reach snet-mgmt directly.

Without segmentation — one breach means full access to everything.
With segmentation — the blast radius is contained to the compromised
layer.

The principle: every layer should only be reachable from the layer
directly above it.
  Internet → app layer → data layer
  Never: Internet → data layer directly

---

### Connection to the Capital One breach (2019)
Attacker compromised an EC2 instance (app layer) and from there
reached S3 buckets (data layer) because no network segmentation
blocked lateral movement. Proper segmentation would have contained
the breach to the single compromised instance. 100 million records
exposed as a result.

---

### Connection refused vs timeout — diagnostic distinction
| Response | Meaning |
|----------|---------|
| Connection refused | Packet reached VM, nothing listening on that port |
| Timeout | Packet never reached VM — NSG or firewall dropped it |

Timeout = network problem — check NSG, ufw, routing
Connection refused = network fine — check if app is running

## Orphaned resource cleanup 

When deleting a VM always check and delete:
- NIC — no cost but clutters the resource group
- OS Disk — costs money even when detached
- Public IP — costs money even when unassociated
- NSG (if VM-specific) — free but clutters

az vm delete only removes the VM itself — associated
resources must be deleted separately or use --ids flag.