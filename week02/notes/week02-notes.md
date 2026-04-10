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