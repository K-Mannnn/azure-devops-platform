# Networking Layers — Traffic path to the voting app

## Current architecture (Week 1)
User → Public Internet → Azure Public IP → NSG → VM NIC → ufw → Flask:80

## Layer breakdown

### Layer 7 — Application
Flask binds to 0.0.0.0:80 — accepts connections on all interfaces.
Diagnostic: curl localhost:80

### Layer 4 — Transport  
TCP port 80. Process: python3 app.py
Diagnostic: ss -tlnp | grep 80

### Layer 3/4 — ufw (OS firewall, inside VM)
Controlled via: sudo ufw allow/deny
Must allow traffic independently of NSG.
Diagnostic: sudo ufw status

### Layer 3/4 — NSG (Azure firewall, outside VM)
Controlled via: az network nsg rule create/update
Rules evaluated lowest priority number first.
Default deny-all rule at priority 65500.
Diagnostic: az network nsg rule list

## Rules currently in place
| Rule | Port | Source | Action | Priority |
|------|------|--------|--------|----------|
| AllowVotingApp | 80 | MY_IP/32 | Allow | 100 |
| default-allow-ssh | 22 | MY_IP/32 | Allow | 1000 |

## What will change each week
- Week 2: Docker adds its own network layer
- Week 3: Terraform manages NSG rules as code
- Week 5: Zero Trust — no public IPs at all


## Week 2 — VNet topology

VNet: vnet-devops (10.0.0.0/16) in rg-networking

| Subnet    | CIDR          | Azure IPs | Purpose              | NSG            |
|-----------|---------------|-----------|----------------------|----------------|
| snet-mgmt | 10.0.0.0/27   | 27        | Bastion, management  | none yet       |
| snet-app  | 10.0.1.0/24   | 251       | App servers          | nsg-snet-app   |
| snet-data | 10.0.2.0/24   | 251       | Databases            | nsg-snet-data  |
| snet-aks  | 10.0.4.0/23   | 507       | Kubernetes pods      | none yet       |

## Network segmentation
snet-data is not reachable from the internet.
Port 5432 only allowed from 10.0.1.0/24 (snet-app).
Traffic must flow through the application layer to reach the data layer.
This applies whether the data layer is a VM, Azure SQL, or a K8s StatefulSet.

## CIDR reference
Usable Azure IPs = 2^(32-prefix) - 5
/27 = 27 IPs | /24 = 251 IPs | /23 = 507 IPs