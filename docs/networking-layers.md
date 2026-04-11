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



### Resolver chain on every Azure VM
App
  → 127.0.0.53 (systemd-resolved — local cache)
    → 168.63.129.16 (Azure internal resolver)
      → devops-lab.internal (private zone — VNet only)
      → public internet (google.com → root → TLD → authoritative)

168.63.129.16 — Azure's virtual IP, intercepted by Azure fabric.
Configured automatically on every VM that joins a VNet. Not a real
server — a virtual IP that Azure routes to its DNS infrastructure.
Handles both jobs: private zone resolution and public DNS forwarding.

### Resolution order on every Azure VM
1. /etc/hosts — checked first, overrides everything
2. /etc/resolv.conf → 127.0.0.53 → 168.63.129.16
3. Private zone (devops-lab.internal) if query matches
4. Public internet if no private match

### Private DNS Zone — devops-lab.internal
Linked to vnet-devops with auto-registration enabled.
Resolves only from inside vnet-devops — NXDOMAIN from outside.
Auto-registration: VM records created/deleted automatically on
VM creation/deletion. TTL 10s on auto-registered records.
Manual records default TTL 3600s.

### Verified
test-server.devops-lab.internal → 10.0.1.10 (manual record)
vm-dns-test-1.devops-lab.internal → 10.0.1.4 (auto-registered)
Both resolve from inside VNet via 168.63.129.16.
Neither resolves from outside — NXDOMAIN confirmed.

### Debug order for any connectivity issue
1. DNS resolving correctly? — dig, nslookup
2. Route to destination exists? — netstat -rn, ip route
3. Firewall/NSG allowing? — ufw status, az network nsg rule list
4. Application listening? — ss -tlnp, curl localhost:PORT