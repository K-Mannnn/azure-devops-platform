## D1 — Azure Mental Model

Full commands in week2 runbook.

### Key things I understood today

- Azure hierarchy from top to bottom:
  Tenant → Management Groups → Subscription → Resource Groups → Resources
  Each level controls something different — identity, policy, billing,
  lifecycle, individual services.

- Subscription is the billing boundary — everything you create rolls up
  to one bill here. Resource group is the lifecycle boundary — delete
  the group, delete everything inside it. These are different concerns
  and easy to confuse early on.

- Resource groups separated by lifecycle — not by type:
  rg-networking: long-lived, VNet and NSGs rarely deleted
  rg-compute: frequently created and destroyed — VMs, AKS
  rg-data: persistent — never delete casually, databases live here
  Teams that skip this structure spend months retrofitting it later.

- Tags are governance — not decoration. mandatory tags from week 2:
  environment, owner, project, week, managed-by
  managed-by=manual changes to managed-by=terraform in week 3.
  That single tag tells anyone looking whether a resource is safe to
  destroy and recreate or was hand-crafted.

- ARM — Azure Resource Manager — every portal click, CLI command, and
  terraform apply calls the same REST API underneath. Terraform's
  azurerm provider is just a structured wrapper around these API calls.
  This demystifies what Terraform is doing — it's not magic, it's just
  making ARM API calls reproducibly from code.

- Pricing breakdown — only compute charges stop when you deallocate:
  VM running: charged per hour
  VM deallocated: free
  OS disk: charged per GB/month regardless of VM state
  Public IP: charged per hour when associated
  VNet, subnets, NSGs, resource groups: always free

- Regions vs availability zones:
  Region = geographic area (West US, UK South)
  Availability Zone = physically separate datacentre within a region
  Availability Set = logical grouping within one datacentre
  Use AZs for high availability across datacentres, sets for within one.

### Questions that came up
- When would you use Management Groups? Enterprise environments with
  multiple subscriptions — apply policy and RBAC across all of them
  from one place. Not needed for a single subscription like ours yet.

---

## D2 — Azure Networking — VNet, Subnets, NSGs

Full commands in week2 runbook.

### Key things I understood today

- CIDR formula — memorised:
  Total IPs = 2^(32-prefix)
  Usable hosts = Total - 2
  Azure usable IPs = Total - 5 (Azure reserves network, gateway, DNS x2, broadcast)

- Subnet sizing is deliberate — not arbitrary:
  snet-mgmt /27 = 27 IPs — management only, handful of resources
  snet-app /24 = 251 IPs — room to scale app servers
  snet-data /24 = 251 IPs — room for multiple databases
  snet-aks /23 = 507 IPs — Azure CNI gives every pod a real VNet IP,
  runs out fast without generous sizing

- Network segmentation principle:
  Every layer only reachable from the layer directly above it.
  Internet → app layer → data layer.
  Never internet → data layer directly.
  snet-data NSG allows port 5432 from 10.0.1.0/24 only.
  If app layer is compromised, blast radius is contained.

- NSG association — two levels:
  Subnet NSG: applies to all resources in the subnet
  NIC NSG: applies to one specific VM
  Both evaluated independently — both must allow traffic.
  Used --nsg "" on VM creation to avoid duplicate NSG on NIC.

- Connection refused vs timeout — critical diagnostic distinction:
  Timeout = packet never reached VM — NSG or firewall dropped it
  Connection refused = packet reached VM, nothing listening on port
  Timeout means network problem. Connection refused means app problem.

- VNet and subnets and NSGs are free — only compute costs money.
  Scaffolding can sit indefinitely at zero cost.

- Orphaned resources cost money:
  az vm delete only removes the VM — NIC, disk, public IP must be
  deleted separately or they linger and cost money.
  Terraform destroy handles this automatically — another reason for IaC.




## Wednesday Bash Challenge — Subnet Calculator

### What I built
Script that takes a CIDR block as an argument and calculates network
address, broadcast, host range, usable hosts and Azure IPs.

### What I learned
- $1 captures first argument passed to the script
- Bitwise operations in bash — << >> & | ~ inside $(( ))
- IP to integer conversion — (A<<24)+(B<<16)+(C<<8)+D
- Integer to IP conversion — shift right and AND with 255 per octet
- Functions in bash — local variables, $1 inside functions
- No spaces around = in assignments — bash is strict about this
- IFS=. splits on dots for IP octet parsing

### What tripped me up
- Space after = breaks variable assignment silently
- local ip=$ with no variable name — needed local ip=$1
- $CIDR vs $1 inside function — function needs its own argument
- Lowercase prefix vs PREFIX — bash variables are case sensitive


# W2D3 - Everything that is DNS

# DNS resolution flowchart

[ You type: www.example.com ]
                │
                ▼
[ Your Device (Browser / OS) ]
                │
                ▼
[ Recursive Resolver ]
(ISP or Public DNS like 8.8.8.8)        
(This is usually your ISP resolver 
however you can change these settings manually  
or some browsers are automatically configured to override ISP resolver 
and go to public one instead such as google.com)
                │
        ┌───────┴────────┐
        │ Cached answer? │
        └───────┬────────┘
your machine or the recursive resolver may have cached answer 
from previous requests to the ip requested if yes then it will 
return the answer to you machine instead for looking further. 
                │Yes
                ▼
        [ Return IP to you ]
                │
                ▼
          [ Connect to site ]
                
                │No
                ▼
     [ Query Root Name Server ]
If recursive server doesn't have cached answer then 
it goes to 1 0f 13 root name servers which are spread all over the planet. 
                │
                ▼
   "Ask the .com TLD server"
The Root name then forwards the reuests to Top Level Domain (TLD)
such as .com, .org, .net etc. The request has to go through 
this route to know which authoritative server (next in line) to go to.                 │
                ▼
     [ Query TLD Server (.com) ]
                │
                ▼
 "Ask authoritative server for example.com"
This is the server that has matching list of relevant DNS:IP pairs.
But it has to come via TLD server to reach the correct autoritative server. 
                │
                ▼
[ Query Authoritative Name Server ]
                │
                ▼
   "Here is the IP: 93.184.216.34"
                │
                ▼
     [ Resolver caches result ]
                │
                ▼
     [ Return IP to your device ]
                │
                ▼
        [ Browser connects ]

The DNS heirarchy is Root Server >> TLD server >> Authoritative server. 

This heirarchy has to be followed to reach the correct authoritative server to get th IP address. 

Only time its not needed is when your machine or recursive resolver has the answer cached from previous sessons. 

# DNS records

* DNS records have followin elements but not limited to. ALthough the list below is what's sufficient for purpose of this programme.

* A / AAAA → where the website lives.   -- analogy: phone number
 This is the ipv4 or ipv6 address for the website

* CNAME → aliases                       -- analogy: nickname
This the name for the domain such as example.com

* MX → where email goes                 -- analogy: mail room
MX record is needed if the website wants to receive emails, this is separate IP stored under MX records for which mail server to send emails to for this particular website. It is not cumpulsory thing, DNS records can not have MX record 
i.e. not every website has MX records, such as landing pages etc.   

* TXT → verification & security         -- analogy: notes, instructions
A TXT record lets a domain publish plain text data that anyone can query via DNS. Its usually instructions and security measures such as “Is this server allowed to send email for this domain?”, 
“Do you actually own this domain?”,
“What security policy should I follow?”

* NS → who’s in charge                  -- analogy: directory owner
This is name of the authoritative name server as in which name server holds the DNS records. 
This is where the DNS heirarchy is important and comes into play. 


# TTL (Time to Live)

* Time to live or TTL is what decides how long a DNS record can be cached on your resolver server. 

* Its helpful to increase speed as without it every website request will have to go to the full DNS route. 

* It includes the whole DNS records mentioned above i.e. A, MX records etc. 


## Azure DNS & Resolver 
# Azure DNS is authoritative, not recursive
Azure DNS (DNS Zones) stores DNS records like:
A, AAAA, CNAME, MX, TXT, NS
It is the source of truth, not the system that answers queries.

* DNS still flows:
    User → Resolver → Root → TLD → Azure DNS → Answer

# Azure internal resolver (168.63.129.16)
A Microsoft-managed recursive DNS resolver with a fixed ip of 168.63.129.16
Automatically available in every Azure Virtual Network (VNet)
What it does:
  * Resolves public internet domains (google.com, etc.)
  * Resolves Azure private/internal DNS names
  * Handles Azure networking DNS features (like Private Link resolution)
What it is NOT:
  * Not your ISP DNS
  * Not globally reachable from the internet
  * Not a replacement for Azure DNS zones
Where it sits:

  * VM → 168.63.129.16 → (Azure DNS + public DNS system)

# Azure Private DNS Zones
What they are:
  * DNS zones that exist only inside Azure VNets
Purpose:
  * Map private names → private IPs

Example:

  * db.internal.contoso.com → 10.0.1.4
  * api.internal.contoso.com → 10.0.1.5

Key properties:

  * Not visible on the public internet
  * Only accessible from linked VNets
  * Used for internal services and microservices

# How resolution works in Azure

Inside a VM:

VM → 168.63.129.16 → Private DNS Zone (if applicable) → IP

If not private:

VM → 168.63.129.16 → Internet DNS → Public IP

# What “Azure internal names” actually means

It refers to:

  * Your private DNS zones
  * Azure service private endpoints
  * Internal VNet-resolvable names

It does NOT mean:

  * All Azure resources globally
  * Other companies’ networks
  * Public Azure-wide name discovery


  # W2D4 - Azure Bastion and Private end points

  🔐 Azure Bastion vs Jumpbox (Why Bastion is better)

In traditional cloud architectures, a jumpbox (bastion host VM) is used as a secure entry point into a private network. You SSH/RDP into the jumpbox, then hop to other VMs inside the VNet. However, this approach introduces operational overhead and security risks.

With Azure Bastion, Azure provides a fully managed alternative that improves security, simplicity, and scalability.

🆚 Key differences

🖥️ Jumpbox (traditional approach)
A manually managed VM inside the VNet
Requires a public IP for access (unless accessed via VPN)
You must:
 * Patch the OS
 * Harden SSH/RDP
 * Monitor and maintain the VM
 * Often becomes a single point of failure
 * Requires opening inbound ports (22/3389) to some extent
 * Scaling requires building additional jumpbox VMs

☁️ Azure Bastion (managed approach)
 * ully managed service deployed inside a VNet
 * rovides RDP/SSH access via the Azure Portal over HTTPS (443)
 * o public IP required on target VMs
 * o need to expose SSH/RDP ports at all
 * icrosoft handles:
 * atching
 * igh availability
 * ardening
 * upports multiple VMs from a single Bastion instance

🔐 Security advantages of Bastion
 * Eliminates public exposure of VMs
 * Reduces attack surface (no open 22/3389 ports)
 * Centralized access control via Azure RBAC + MFA
 * No need to manage OS-level security on a jumpbox VM

⚙️ Operational advantages
 * No VM maintenance (unlike jumpbox)
 * Faster setup (no custom VM configuration required)
 * Scales across many VMs in the same VNet or peered VNets
 * Browser-based access (no need for local SSH/RDP clients)

 # W2D5 -- Azure Monitor, Cost Controls, and the Operational Baseline

 Today I'm learnt about Azure Monitor and its components such as Log analytics workspace, KQL (Kusto Query Language), Alerts etc. 

 The key components of Azure monitor are: 

 * Resources -- where logs come from

 * Azure Log analytics workspace -- where the logs go, you run KQL queries here. 

 * Metrics Store - used for charts etc. but handled by Azure so no set up required

 * Azure Monitor Agent 

 * Data Collection Rules

 * Analysis tools such as KQL, VM insights, Workbooks (dashboards)

 * Alerts -- sets rules and trigger emails. 

 Azure Log analytics workspace

 * Azure Log Analytics Workspace is basically a central storage + analysis environment for logs and telemetry data in Azure

 * Its part of Azure monitor and essentially brain for all the logging data in Azure. 

 * You can send logs to Log analytics workspace from different resources such VMs, Storgae, networking etc. 
  - Resources → Log Analytics Workspace → KQL Queries → Insights / Alerts
 
 * Enables monitoring + security + troubleshooting in one place

 * Uses KQL for fast querying

 Created the Log analytics workspace and directed traffic from nsg-snet-app and vnet-devops into it. However ran into issue when created the VM as correct nsg wasn't being applied. 

 Diagnostic settings were only set to NetworkSecurityGroupEvent" and "NetworkSecurityGroupRuleCounter" to start with and no logs were produced. Changed the setting to all logs and logs started to appear. 
 
 Resource emits categories → only if category actually produces events
→ only then sent to workspace