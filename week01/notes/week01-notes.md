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