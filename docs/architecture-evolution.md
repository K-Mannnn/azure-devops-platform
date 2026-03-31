# Architecture Evolution

## Week 1 — Manual VM

The starting point. One VM, one service, everything done by hand.

\```
Internet (port 5000)
        |
        v
  [Azure NSG]
        |
        v
[Azure VM — Standard_B2pls_v2]
  - Ubuntu 22.04
  - Flask vote service (python3 app.py)
  - systemd managed
  - ufw enabled
\```

### What exists
- Single VM provisioned manually via Azure CLI
- App deployed by hand — git clone, pip install, systemd service
- NSG rules created manually per session
- No automation, no reproducibility guarantee

### What's missing
- Redis, worker, result service — app only half works
- No Docker — dependencies installed directly on OS
- No IaC — VM cannot be reproduced reliably
- No CI/CD — deployment is manual SSH

### Next week
Docker — the full voting app stack running in containers.
The manual install pain disappears. The Redis error gets fixed.