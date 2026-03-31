#!/bin/bash
# VM auto-deallocate script via SSH

VM_USER="azureuser"
VM_IP="172.185.17.140"


echo "=== VM Runtime Check ==="
echo "TIME: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

ssh -i ~/.ssh/newKey ${VM_USER}@${VM_IP} '

VM="vm-arm-b2pts-01"
RG="rg-devops-wus1"
THRESHOLD=120

# Get VM status
VM_status=$(az vm get-instance-view \
  --name "$VM" \
  --resource-group "$RG" \
  --query "instanceView.statuses[?starts_with(code, '\''PowerState/'\'')].code" \
  -o tsv)

# Clean status for readability
if [[ "$VM_status" == "PowerState/running" ]]; then
    STATUS="running"
else
    STATUS="not running"
fi

# Get uptime
uptime_seconds=$(az vm run-command invoke \
    --resource-group "$RG" \
    --name "$VM" \
    --command-id RunShellScript \
    --scripts "awk '\''{print int(\$1)}'\'' /proc/uptime" \
    -o tsv | tr -d "\r")

# Calculate boot time and runtime
current_epoch=$(date +%s)
boot_epoch=$(( current_epoch - uptime_seconds ))
boot_time=$(date -d "@$boot_epoch" "+%Y-%m-%d %H:%M:%S")
runtime_minutes=$(( uptime_seconds / 60 ))

# Output
echo "VM: $VM"
echo "Status: $STATUS"
echo "Running since: $boot_time"
echo "Runtime: $runtime_minutes minutes"
echo "Threshold: $THRESHOLD minutes"
echo ""

# Check threshold
if [[ "$runtime_minutes" -le "$THRESHOLD" && "$STATUS" == "running" ]]; then
    echo "OK — within limit. No action taken."
else
    echo "WARNING — threshold exceeded. Deallocating VM..."
    az vm deallocate --resource-group "$RG" --name "$VM"
    echo "Done."
fi
'