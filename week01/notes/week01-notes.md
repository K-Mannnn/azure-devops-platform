# W1 Monday — Bash Challenge

## What I built
Script to SSH into the VM and print system state in one shot.

## What I learned
- SSH command blocks — commands in single quotes run on the remote machine, not locally
- awk quoting breaks inside single-quoted SSH blocks — fix with double quotes and escape \$
- free, df, ps piped into awk to pull specific fields

## What tripped me up
- awk fatal error — caused by single quotes conflicting inside the SSH block
- date typo — `date:` and `%D` instead of `date` and `%d`


=============================================

## D2 — Linux as Your Cockpit
Full commands and issues in week1-manual-runbook.md.

Key things I understood today:
- SIGTERM vs SIGKILL — graceful vs immediate, matters for stateful apps
- systemd = poor man's Kubernetes — same restart-on-failure concept
- Port hardcoded in app.py — environment variables only work if the app reads them
- df vs du answer different questions — df first in any incident
- Redis connection error — running one piece of a multi-service app in isolation
  always fails at the integration points. The vote service expects a Docker network
  where 'redis' resolves to a container by name. On a bare VM that DNS doesn't exist.
  This is the exact problem Docker Compose solves in Week 2 — you've now felt why
  it exists, not just read about it.





## D3 — The Snowflake Problem


### Key things I understood today

- The snowflake problem isn't always catastrophic failure — it's the subtle
  friction that adds up. Every session this week recreating the VM produced
  small issues: wrong SSH key,  port hardcoded in
  app.py, NSG rules forgotten, sudo vs user Python environment. None
  individually catastrophic. All of them together at 2am on a production
  outage would be a serious problem.

- If you cannot recreate it, you cannot recover it. GitLab deleted their
  production database in 2017 and took 18 hours to partially recover because
  their backup and recovery processes were manual and untested. Same root
  cause as our VM rebuilds — manual operations on systems that aren't fully
  documented or reproducible.

- Every line in the runbook is a future incident. Each manual step is
  something that can go wrong, be forgotten, or be done in the wrong order
  under pressure.

- Recovery time depends entirely on one markdown file and one person's memory.
  No automated verification that the rebuild matches the original. No way to
  guarantee package versions or config state. This is unacceptable at scale.

- ADR format — how senior engineers document decisions for future teammates
  including their future selves. Context (the problem), Decision (what we're
  doing), Consequences (what it enables and costs). Hiring managers who see
  ADRs in a portfolio think: this person thinks like someone who has worked
  on real teams.

- Written ADR 001 — Why We Need IaC. The evidence for the decision is
  everything that happened this week. Terraform recreates this in 3 minutes
  in Week 3. That number will feel significant having lived the manual version.

### Questions that came up
- What's the difference between apt packages explicitly installed vs pulled
  in as dependencies? apt-mark showmanual shows only what you explicitly
  installed — the rest follow automatically. Matters when recreating a server.






## D4 — Networking Reality Check

Full commands and issues in week1-manual-runbook.md.

### Key things I understood today

- Traffic reaches the app through multiple independent layers — each one can
  silently block it. Just because the app is running doesn't mean it's reachable.

- Debug methodology — always inside out:
  1. curl localhost:80 — is the app responding at all? (Layer 7)
  2. ss -tlnp — is the port listening? (Layer 4)
  3. sudo ufw status — is the OS firewall blocking? (Layer 3/4, inside VM)
  4. az network nsg rule list — is Azure blocking? (Layer 3/4, outside VM)
  Fix the innermost problem first. If the app isn't running, checking NSG rules
  is a waste of time.

- NSG is created automatically when you run az vm create — Azure attaches it
  to the VM's NIC and adds a default SSH rule on port 22. az vm open-port
  just adds rules to that existing NSG.

- ufw and NSG are completely independent — both must allow traffic for it
  to flow. NSG lives outside the VM in Azure's network fabric. ufw lives
  inside the VM in the OS. The VM cannot see or override the NSG.
  Proved this by allowing traffic in the NSG but blocking with ufw —
  app was still unreachable.

- Never leave rules open to 0.0.0.0/0 beyond the testing moment. Locked
  both port 80 and SSH to MY_IP/32 — /32 means exactly one IP address.
  A bank left port 22 open to 0.0.0.0/0 and got compromised in 6 hours.

- NSG priority system — lower number = evaluated first. Your rules sit above
  Azure's default deny-all at priority 65500. Rule at priority 100 is checked
  before a rule at priority 200.

- curl localhost:80 bypasses both firewalls entirely — goes straight to the
  app. This is why it's the first diagnostic step. If this fails, it's an
  app problem not a network problem.

- Flask must bind to 0.0.0.0 not 127.0.0.1 — 127.0.0.1 only accepts
  connections from inside the VM. 0.0.0.0 accepts from any interface,
  which is what allows external traffic through once the firewalls allow it.

### What will change each week
- Week 2: Docker adds its own network layer
- Week 3: Terraform manages NSG rules as code — no more manual az commands
- Week 5: Zero Trust — no public IPs at all