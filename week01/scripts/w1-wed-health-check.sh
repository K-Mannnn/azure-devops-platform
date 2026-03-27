#!/bin/bash
# W1 Bash Challenge — Wednesday
# Challenge: Remote system health check summary in one script


VM_IP="20.66.115.34"
VM_USER="azureuser"
Healthy=true

echo "=== Voting App Health Check ==="
echo "TIME: $(date '+%Y-%m-%d %H:%M:%S')"



echo "Process: "

if ssh -i ~/.ssh/newKey ${VM_USER}@${VM_IP} 'pgrep -f "python3 app.py"' > /dev/null; then
    echo "running (PID=$(ssh -i ~/.ssh/newKey ${VM_USER}@${VM_IP} 'pgrep -f "app.py" | head -n1'))"
else
    echo "Not running"
    Healthy=false
fi 


echo "Port 5000: "

if ssh -i ~/.ssh/newKey ${VM_USER}@${VM_IP} 'ss -tlnp | grep :5000' > /dev/null; then
    echo "listening"
else 
    echo "NOT listening"
    Healthy=false

fi

echo "HTTP: "


status_code=$(curl -s -o /dev/null -w "%{http_code}" http://$VM_IP:5000)

if [ "$status_code" = "200" ]; then
    echo  "$status_code OK"
else
    echo "got $status_code (expected 200)"
    Healthy=false
fi

# final result

if [ "$Healthy" = true ]; then 
    exit 0
else exit 1

fi