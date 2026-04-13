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


# W2D3 - Everything that is DNS

Creating a new VM for DNS testing: ALthough needed 2 VMs for full DNS testing but due quota limitations making it work with just 1. 

az vm create \
  --name vm-dns-test-1 \
  --resource-group rg-compute \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-arm64:latest \
  --size Standard_B2pts_v2 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --subnet "/subscriptions/b73aa262-f80d-4fbf-8cc3-549feae1e348/resourceGroups/rg-networking/providers/Microsoft.Network/virtualNetworks/vnet-devops/subnets/snet-app"
  --nsg "" \
  --tags environment=dev managed-by=manual week=2 

* ssh into the VM

sudo apt install -y dnsutils

dig +trace google.com
dig google.com +short
dig google.com @8.8.8.8 +short
dig google.com @168.63.129.16 +short
cat /etc/resolv.conf
resolvectl status


#### What the dig +trace showed
Full resolution chain for google.com:
127.0.0.53 → i.root-servers.net → l.gtld-servers.net → ns2.google.com → 172.217.12.110

Hop 1 — Root nameservers
Query started at local resolver 127.0.0.53 (systemd-resolved).
Returned the 13 root nameservers. TTL 513027s (~6 days) — cached heavily.
IPv6 errors appeared (network unreachable) — VM has no IPv6, fell back
to IPv4 automatically. Normal behaviour.

Hop 2 — TLD nameservers
Root server i.root-servers.net returned 13 gtld-servers for .com.
TTL 172800s (48 hours). Also returned DNSSEC signatures (DS, RRSIG)
— ignore for now.

Hop 3 — Authoritative nameservers
TLD server l.gtld-servers.net returned Google's own nameservers:
ns1-4.google.com. TTL 172800s (48 hours).

Hop 4 — Final answer
Google's ns2.google.com returned 172.217.12.110.
TTL 300s (5 minutes) — Google keeps this low for IP rotation across
their global server fleet. Total resolution time ~225ms across 3 hops.

#### Interesting observations
- dig @8.8.8.8 returned a different Google IP (142.251.219.14) than
  the default resolver. Both valid — Google load balances across many
  IPs globally. Different resolvers route to different datacentres.

- /etc/resolv.conf shows nameserver 127.0.0.53 — that's systemd-resolved
  running locally on the VM as a caching layer. It forwards upstream
  to 168.63.129.16 (Azure's resolver).

- resolvectl status confirmed:
  Current DNS Server: 168.63.129.16
  Azure injected this automatically when the VM joined the VNet.
  No manual configuration needed.

- Search domain auto-configured by Azure:
  xrz3452bog5etdjoxhiarygbza.dx.internal.cloudapp.net
  Allows short hostname resolution between VMs in the same VNet
  without typing the full domain.

#### Full resolver chain
App → 127.0.0.53 (systemd-resolved, local cache)
    → 168.63.129.16 (Azure resolver)
      → private zones (devops-lab.internal)
      → public internet (google.com → root → TLD → authoritative)


### Created private DNS zone

az network private-dns zone create \
  --resource-group rg-networking \
  --name devops-lab.internal

### Linked it to existing vnet

az network private-dns link vnet create \
  --resource-group rg-networking \
  --zone-name devops-lab.internal \
  --name link-vnet-devops \
  --virtual-network vnet-devops \
  --registration-enabled true

# List records — check auto-registration
az network private-dns record-set list \
  --resource-group rg-networking \
  --zone-name devops-lab.internal \
  --output table

# Add manual A record
az network private-dns record-set a add-record \
  --resource-group rg-networking \
  --zone-name devops-lab.internal \
  --record-set-name test-server \
  --ipv4-address 10.0.1.10

# Verify from inside VNet
dig test-server.devops-lab.internal @168.63.129.16
dig vm-dns-test-1.devops-lab.internal @168.63.129.16

# Verify does NOT resolve from outside
dig test-server.devops-lab.internal


#### What happened
Private DNS zone devops-lab.internal created as a global resource —
not tied to a region, linked to VNets instead.

Auto-registration proved — the moment the VNet link was established
Azure automatically created an A record for vm-dns-test-1:
  vm-dns-test-1.devops-lab.internal → 10.0.1.4
  isAutoRegistered: true, TTL: 10s
Azure keeps auto-registered TTL low (10s) so DNS updates quickly
when VMs are created or deleted.

Manual record added:
  test-server.devops-lab.internal → 10.0.1.10
  TTL: 3600s (1 hour) — default for manual records

#### Verification results
From inside VNet (via 168.63.129.16):
  test-server.devops-lab.internal → 10.0.1.10  NOERROR ✅
  vm-dns-test-1.devops-lab.internal → 10.0.1.4  NOERROR ✅
  Response time: 3ms

From local machine (via home router 192.168.1.254):
  test-server.devops-lab.internal → NXDOMAIN ✅
  Private zone genuinely not reachable from outside the VNet.

#### Key concepts proved
- Private DNS zones are truly private — NXDOMAIN from outside confirms it
- Auto-registration removes manual DNS management for VMs entirely
- 168.63.129.16 handles both private zone resolution and public DNS
  forwarding — one resolver, two jobs
- Private zone location is global — linked to VNets not regions

#### TTL implications
TTL on test-server record: 3600s (1 hour)
A record with TTL 3600 takes up to 1 hour to propagate after changes.

DNS cutover procedure:
1. Reduce TTL to 60s
2. Wait 1 hour for existing cached records to expire
3. Make the DNS change
4. Verify resolution is correct
5. Restore TTL to 3600

Why wait an hour after reducing TTL? Records cached before the TTL
reduction still have up to 3600s left. Must wait for all caches to
expire before the new low TTL takes effect.


### W2D4 -- Azure Bastion and Private End Points

# Create a storage account

# Storage account names must be globally unique, lowercase, 3-24 chars
az storage account create \
  --name devopsevolution$RANDOM \
  --resource-group rg-data \
  --location westus \
  --sku Standard_LRS \
  --tags environment=dev managed-by=manual week=2


# Retrieve the Storgae account FQDN: 

az storage account show \
  --name devopsevolution2852 \
  --resource-group rg-data \
  --query primaryEndpoints.blob \
  --output tsv


# Get the storage account resource ID
STORAGE_ID=$(az storage account show \
  --name <YOUR_STORAGE_NAME> \
  --resource-group rg-data \
  --query id \
  --output tsv)

# Create private endpoint
az network private-endpoint create \
  --name pe-storage \
  --resource-group rg-networking \
  --vnet-name vnet-devops \
  --subnet snet-data \
  --private-connection-resource-id $STORAGE_ID \
  --group-id blob \
  --connection-name pe-storage-connection \
  --tags environment=dev managed-by=manual week=2

az network private-dns zone create \
  --resource-group rg-networking \
  --name privatelink.blob.core.windows.net

az network private-dns link vnet create \
  --resource-group rg-networking \
  --zone-name privatelink.blob.core.windows.net \
  --name link-storage \
  --virtual-network vnet-devops \
  --registration-enabled false

# Create DNS zone group — links private endpoint to DNS zone
az network private-endpoint dns-zone-group create \
  --resource-group rg-networking \
  --endpoint-name pe-storage \
  --name storage-zone-group \
  --private-dns-zone privatelink.blob.core.windows.net \
  --zone-name blob

# Testing the private and public endpoints

* From your laptop
dig devopsevolution2852.blob.core.windows.net

- resolved to a public IP. 

ssh azureuser@<Your_VM>

dig devopsevolution2852.blob.core.windows.net

- resolved to a private IP

# Disable the public access:

az storage account update \
  --name <YOUR_STORAGE_NAME> \
  --resource-group rg-data \
  --public-network-access Disabled

# Test access fro your laptop

az storage blob list \
  --account-name <YOUR_STORAGE_NAME> \
  --container-name test \
  --auth-mode login

* access denied. 

# On the VM
curl -I https://<YOUR_STORAGE_NAME>.blob.core.windows.net

- Private end poit reached successfully. 

# Deploy Bastion

# Create the required subnet 
az network vnet subnet create \
  --name AzureBastionSubnet \
  --vnet-name vnet-devops \
  --resource-group rg-networking \
  --address-prefix 10.0.0.64/26

# Create public IP for Bastion 
az network public-ip create \
  --name pip-bastion \
  --resource-group rg-networking \
  --sku Standard \
  --location westus \
  --tags environment=dev managed-by=manual week=2

# Deploy Bastion 
az network bastion create \
  --name bastion-devops \
  --resource-group rg-networking \
  --vnet-name vnet-devops \
  --public-ip-address pip-bastion \
  --location westus \
  --tags environment=dev managed-by=manual week=2

# Test connection to VM via Bastion

az network bastion ssh \
  --name bastion-devops \
  --resource-group rg-networking \
  --target-resource-id $(az vm show \
    --resource-group rg-compute \
    --name vm-dns-test-1 \
    --query id --output tsv) \
  --auth-type ssh-key \
  --username azureuser 

* Failed due to Bastion Sku being basic and minimum required for SSH is Standard or Premium

az network bastion update \
  --name bastion-devops \
  --resource-group rg-networking \
  --sku "{name:Standard}"

* Also need to toggle 'Native Client Support' in the Azure portal. 

az network bastion ssh \
  --name bastion-devops \
  --resource-group rg-networking \
  --target-resource-id $(az vm show \
    --resource-group rg-compute \
    --name vm-dns-test-1 \
    --query id --output tsv) \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/Your_Key

- ssh successful!! 

