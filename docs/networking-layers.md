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