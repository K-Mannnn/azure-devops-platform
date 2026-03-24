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