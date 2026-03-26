#!/bin/bash
# W1 Bash Challenge — Monday
# Challenge: Remote system state summary in one script
# Why it matters: Every incident starts with orienting yourself on the server.
#                 This automates what you did manually on Day 1.

VM_IP="104.40.39.212"
VM_USER="azureuser"

echo "=== VM System State ==="
echo "Date:     $(date '+%Y-%m-%d %H:%M:%S')"

ssh -i ~/.ssh/new_Key ${VM_USER}@${VM_IP} '

  echo "Hostname: $(hostname)"
  echo "Kernel:   $(uname -s) $(uname -r)"
  echo "Arch:     $(uname -m)"

  echo ""
  echo "--- Disk ---"
  df -h | head -n 2

  echo ""
  echo "--- Memory (MB) ---"
  echo "Total: $(free -m | awk "/^Mem:/ {print \$2}")"
  echo "Used:  $(free -m | awk "/^Mem:/ {print \$3}")"
  echo "Free:  $(free -m | awk "/^Mem:/ {print \$4}")"

  echo ""
  echo "--- Top 5 Processes by CPU ---"
  ps aux --sort=-%cpu | head -6 | awk "{print \$2, \$3, \$11}"

'

echo "======================"